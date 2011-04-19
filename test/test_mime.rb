require_relative 'helper'
require_relative '../lib/podgraph/posterous'

class TestMime < MiniTest::Unit::TestCase
  def setup
    @testdir = File.expand_path(File.dirname(__FILE__))
    @to = 'alex@goliard'
    @from = 'alexander.gromnitsky@gmail.com'
    @conf = {}
    @u = Trestle.new @conf
  end
  
  def test_broken_subject
    e = assert_raises(RuntimeError) {
      p = Podgraph::Posterous.new(@u, @testdir+'/nosubject.html', @to,
                                  @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_missing_input_file
    e = assert_raises(Errno::ENOENT) {
      p = Podgraph::Posterous.new(@u, 'something_completly_unreliable.html',
                                  @to, @from, 'related')
    }
    assert_match(/no such file or directory/i, e.message)
  end

  def test_empty_input_file
    e = assert_raises(RuntimeError) {
      p = Podgraph::Posterous.new(@u, @testdir+'/empty.html',
                                  @to, @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_invalid_input_file_01
    e = assert_raises(RuntimeError) {
      p = Podgraph::Posterous.new(@u, @testdir+'/garbage_01.html',
                                  @to, @from, 'related')
    }
    assert_match(/cannot extract the subject/, e.message)
  end

  def test_invalid_input_file_02
    assert_raises(REXML::ParseException) {
      p = Podgraph::Posterous.new(@u, @testdir+'/garbage_02.html',
                                  @to, @from, 'related')
    }
  end

  def test_invalid_input_file_03
    e = assert_raises(RuntimeError) {
      p = Podgraph::Posterous.new(@u, @testdir+'/garbage_03.html',
                                  @to, @from, 'related')
    }
    assert_match(/body is empty or filled with nonsence/, e.message)
  end

  def test_invalid_input_file_04
    e = assert_raises(RuntimeError) {
      p = Podgraph::Posterous.new(@u, @testdir+'/garbage_04.html',
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
    p = Podgraph::Posterous.new(@u, @testdir+'/simple.html', @to, @from, 'related')
    mail = p.generate().to_s
    mail.sub!(/^Date: .+$\n/, '')
    mail.sub!(/^Message-ID: .+$\n/, '')
    mail.sub!(/^user-agent: .+$\n/, '')
#    p mail
#    puts mail
    assert_equal('0d75d9f8e42b3c2544684cbbec83b1ed',
                 Digest::MD5.hexdigest("#{mail}") )
  end

  def test_related
    p = mail = nil
    Dir.chdir(@testdir) do
      p = Podgraph::Posterous.new(@u, @testdir+'/related.html', @to, @from, 'related')
      mail = p.generate()
    end
    assert_equal(mail.multipart?, true)
    assert_equal(mail.parts.length, 3) # html and 2 images
    # check for 2 images
    assert_equal(p.o[:a_marks].key?('blue.png'), true)
    assert_equal(p.o[:a_marks].key?('yellow.png'), true)

    # html
    assert_equal(mail.parts[0].content_type, "text/html; charset=UTF-8")
    refute_equal(mail.parts[0].content_disposition, "inline")
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
      p = Podgraph::Posterous.new(@u, 'related.html', @to, @from, 'mixed')
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
    refute_equal(mail.parts[1].content_disposition, "inline")
    refute_equal(mail.parts[2].content_disposition, "inline")
  end
  
end
