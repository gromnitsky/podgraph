require 'uri'
require 'digest'
require 'base64'

require 'nokogiri'
require 'mail'

class Transformer
  def initialize html
    @doc = Nokogiri.HTML html
    svg!
    pre!
    @images = raster_images!
  end
  attr_reader :images

  # inline svg; I've tried a straight xml insertion, but Blogger's freaked out
  def svg!
    attr = ->(node) { ['src', 'data'].find {|k| node[k]} }
    @doc.css('img,iframe,embed,object[type="image/svg+xml"]').select do |node|
      src = attr.call node
      Transformer.local_img?(node, ['src', 'data']) && MiniMime.lookup_by_filename(node[src])&.content_type == 'image/svg+xml'
    end.each do |node|
      src = attr.call node
      node[src] = "data:image/svg+xml;base64,#{Base64.strict_encode64(File.read node[src])}"
    end
  end

  # replace every newline in <pre> with <br>, because Blogger
  def pre!
    @doc.css('pre').select do |node|
      text = node.to_s.gsub(/\n/, '<br>')
      node.replace Nokogiri.HTML(text).css('pre')
    end
  end

  # return local images; relink each affecter <img>
  def raster_images!
    images = {}
    @doc.css('img').select do |img|
      Transformer.local_img? img
    end.each do |img|
      fail "unsupported file format: #{img['src']}" if !MiniMime.lookup_by_filename img['src']

      sha1 = Digest::SHA1.hexdigest File.read img['src']
      images[sha1] ||= { name: img['src'] }
      img['src'] = "cid:#{sha1}"
    end
    images
  end

  def subject
    @subject ||= begin
                   node = @doc.css('h1,h2,h3,h4').first
                   return 'no subject' unless node
                   text = node.text
                   node.remove
                   text
                 end
  end

  def html; @doc.to_s; end

  def self.local_img? node, attr = ['src'] # TODO: allow file:// scheme
    attr.any? do |k|
      node[k] && node[k].strip.size > 0 &&
        !node[k].start_with?('data:') && !URI(node[k]).scheme
    end
  end
end

class MailGenerator
  def initialize tr, recipients = []
    @tr = tr
    @mail = Mail.new
    @mail.to = recipients
    @mail.subject = tr.subject
    tr.images.empty? ? simple : multipart_related
  end

  def to_s; @mail.to_s; end

  def simple
    @mail.content_disposition 'inline'
    @mail.content_type 'text/html; charset="UTF-8"'
    @mail.body @tr.html
  end

  def multipart_related
    @mail.content_type 'Multipart/Related'
    html = @tr.html
    @mail.html_part do
      content_type 'text/html; charset=UTF-8'
      body html
    end

    @tr.images.each do |k,v|
      @mail.add_file v[:name]
      @mail.parts.last.content_disposition 'inline'
      @mail.parts.last.content_id "<#{k}>"
    end
  end
end
