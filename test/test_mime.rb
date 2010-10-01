require 'test/unit'
require 'digest/md5'

require_relative '../lib/podgraph/posterous'

class TestMime < Test::Unit::TestCase
  def setup
    @testdir = File.expand_path(File.dirname(__FILE__))
    @to = 'alex@goliard'
    @from = 'alexander.gromnitsky@gmail.com'
  end
  
  def test_broken_subject
    e = assert_raise(RuntimeError) {
      p = Podgraph::Posterous.new(@testdir+'/nosubject.html', @to,
                                  @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_missing_input_file
    e = assert_raise(Errno::ENOENT) {
      p = Podgraph::Posterous.new('something_completly_unreliable.html',
                                  @to, @from, 'related')
    }
    assert_match(/no such file or directory/i, e.message)
  end

  def test_empty_input_file
    e = assert_raise(RuntimeError) {
      p = Podgraph::Posterous.new(@testdir+'/empty.html',
                                  @to, @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_invalid_input_file_01
    e = assert_raise(RuntimeError) {
      p = Podgraph::Posterous.new(@testdir+'/garbage_01.html',
                                  @to, @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_invalid_input_file_02
    assert_raise(REXML::ParseException) {
      p = Podgraph::Posterous.new(@testdir+'/garbage_02.html',
                                  @to, @from, 'related')
    }
  end

  def test_invalid_input_file_03
    e = assert_raise(RuntimeError) {
      p = Podgraph::Posterous.new(@testdir+'/garbage_03.html',
                                  @to, @from, 'related')
    }
    assert_match(/body is empty or filled with nonsence/, e.message)
  end

  def test_invalid_input_file_04
    e = assert_raise(RuntimeError) {
      p = Podgraph::Posterous.new(@testdir+'/garbage_04.html',
                                  @to, @from, 'related')
      mail = p.generate()
    }
    assert_match(/cannot attach/, e.message)
  end
  
  
  # NOTE: run
  #
  # % ../bin/podgraph -S simple.html | grep -v -e ^Date: -e ^Message-ID: -e '^user-agent:'|md5
  #
  # to get a new hash for this test
  def test_simple
    p = Podgraph::Posterous.new(@testdir+'/simple.html', @to, @from, 'related')
    mail = p.generate().to_s
    mail.sub!(/^Date: .+$\n/, '')
    mail.sub!(/^Message-ID: .+$\n/, '')
    mail.sub!(/^user-agent: .+$\n/, '')
#    p mail
#    puts mail
    assert_equal('ffaf6609a4544258e59dfde9f766820f',
                 Digest::MD5.hexdigest("#{mail}\n") ) # don't forget a newline!
  end

  def test_related
    p = mail = nil
    Dir.chdir(@testdir) do
      p = Podgraph::Posterous.new(@testdir+'/related.html', @to, @from, 'related')
      mail = p.generate()
    end
    assert_equal(mail.multipart?, true)
    assert_equal(mail.parts.length, 3) # html and 2 images
    # check for 2 images
    assert_equal(p.o[:a_marks].key?('blue.png'), true)
    assert_equal(p.o[:a_marks].key?('yellow.png'), true)

    # html
    assert_equal(mail.parts[0].content_type, "text/html; charset=UTF-8")
    assert_not_equal(mail.parts[0].content_disposition, "inline")
    assert_equal(mail.parts[1].content_disposition, "inline")
    assert_equal(mail.parts[2].content_disposition, "inline")

    # search in the html our inline images
    mail.parts[1..-1].each {|i|
      assert_match(Regexp.new("cid:#{i.content_id[1..-1]}"),
                   mail.parts[0].body.decoded)
    }
  end

  def test_mixed
    p = mail = nil
    Dir.chdir(@testdir) do
      p = Podgraph::Posterous.new('related.html', @to, @from, 'mixed')
      mail = p.generate()
    end
    assert_equal(mail.multipart?, true)
    assert_equal(mail.parts.length, 3) # html and 2 images
    # check for 2 images
    assert_equal(p.o[:attachment].include?('blue.png'), true)
    assert_equal(p.o[:attachment].include?('yellow.png'), true)

    # html
    assert_equal(mail.parts[0].content_type, "text/html; charset=UTF-8")
    assert_equal(mail.parts[0].content_disposition, "inline")
    assert_not_equal(mail.parts[1].content_disposition, "inline")
    assert_not_equal(mail.parts[2].content_disposition, "inline")
  end
  
end
