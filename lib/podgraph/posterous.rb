gem 'mail', '= 2.1.3'
require 'mail'
require 'active_support/core_ext/module/attribute_accessors'

require 'rexml/document'
require 'yaml'
require 'optparse'

# :include: ../../README.rdoc
module Podgraph

  VERSION = '0.0.3'
  mattr_accessor :cfg
  
  self.cfg = Hash.new()
  cfg[:verbose] = 0

  def self.veputs(level, s)
    puts(s) if cfg[:verbose] >= level
  end

  # Reads XHTML file, analyses it, finds images, checks if they can be inlined,
  # generates multipart/relative or multipart/mixed MIME mail.
  class Posterous

    # some options for mail generator; change with care
    attr_accessor :o

    # Analyses _filename_. It must be a XHTML file.
    # _to_, _from_ are email.
    # _mode_ is 1 of 'related' or 'mixed' string.
    def initialize(filename, to, from, mode)
      @o = Hash.new()
      @o[:user_agent] = 'podgraph/' + VERSION
      @o[:subject] = ''
      @o[:body] = []
      @o[:attachment] = []
      @o[:a_marks] = {}
      @o[:mode] = mode
      @o[:to] = to
      @o[:from] = from

      fp = File.new(filename)
      begin
        make(fp)
      rescue
        raise $!
      ensure
        fp.close()
      end
    end

    def make(fp)
      xml = REXML::Document.new(fp)
      begin
        @o[:subject].replace(REXML::XPath.first(xml, "/html/body/div/h1").text.gsub(/\s+/, " "))
        raise if @o[:subject] =~ /^\s*$/
      rescue
        raise 'cannot extract the subject from <h1>'
      end

      img_collect = ->(i, a) {
        if i.name == 'img'
          if (src = i.attributes['src']) =~ /^\s*$/
            raise '<img> tag with missing or empty src attribute'
          elsif src =~ /\s*(http|ftp):\/\//
            # we are ignoring URL's
            return
          else
            a << src
            if @o[:mode] == 'related'
              # replace src attribute with a random chars--later
              # we'll replace such marks with corrent content-id
              random = Mail.random_tag()
              i.attributes['src'] = random
              @o[:a_marks][src] = random   # save an act of the replacement
              
              @o.rehash()                  # is this really necessary?
            end
          end
        end
      }
      
      f = 1
      xml.elements.each('/html/body/div/*') { |i|
        if f == 1
          f = 0                     # skip first <h1>
          next
        end

        Podgraph::veputs(2, "node: #{i.name}")
        img_collect.call(i, @o[:attachment])
        i.each_recursive { |j|
          Podgraph::veputs(2, "node recursive: #{j.name}")
          img_collect.call(j, @o[:attachment])
        }
        
        @o[:body] << i
      }

      raise "body is empty or filled with nonsence" if @o[:body].size == 0
    end
    private :make

    # Returns ready for delivery Mail object.
    def generate()
      m = Mail.new()
      m.from(@o[:from])
      m.to(@o[:to])
      m.content_transfer_encoding('8bit')
      m.subject(@o[:subject])
      m.headers({'User-Agent' => @o[:user_agent]})

      Podgraph::veputs(2, "Body lines=#{@o[:body].size}, bytes=#{@o[:body].to_s.bytesize}")
      if @o[:attachment].size == 0
        m.content_disposition('inline')
        m.content_type('text/html; charset="UTF-8"')
        m.body(@o[:body])
      else
        if @o[:mode] == 'related'
          m.content_type('Multipart/Related')
        end
        m.html_part = Mail::Part.new {
          content_transfer_encoding('8bit')
          content_type('text/html; charset=UTF-8')
        }
        m.html_part.body = @o[:body]
        m.html_part.content_disposition('inline') if @o[:mode] == 'mixed'
        
        begin
          @o[:attachment].each { |i| m.add_file(i) }
        rescue
          raise("cannot attach: #{$!}")
        end

        if @o[:mode] == 'related'
          if (fqdn = Socket.gethostname() ) == ''
            raise 'hostname is not set!'
          end
          cid = {}
          m.parts[1..-1].each { |i|
            i.content_disposition('inline')
            cid[i.filename] = i.content_id("<#{Mail.random_tag}@#{fqdn}.NO_mail>")
          }

          @o[:a_marks].each { |k, v|
            if cid.key?(k)
              Podgraph::veputs(2, "mark #{k} = #{v}; -> to #{cid[k]}")
              # replace marks with corresponding content-id
              m.html_part.body.raw_source.sub!(v, "cid:#{cid[k][1..-1]}")
            else
              raise("orphan key in cid: #{k}")
            end
          }
        end
      end # a.size
      
      return m
    end
  
    # Print Mail object to stdout.
    # _e_ is an optional encoding.
    def dump(e = '')
      puts (e == '' ? generate().to_s : generate().to_s.encode(e))
    end
    
  end # Posterous
  
end # Podgraph
