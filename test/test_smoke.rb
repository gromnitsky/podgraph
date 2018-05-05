require_relative '../lib'
require 'minitest/autorun'

class TestTransformer < Minitest::Test
  def test_local_img
    refute Transformer.local_img?('src' => "http://example.com")
    refute Transformer.local_img?('src' => '')
    refute Transformer.local_img?({})
    assert Transformer.local_img?('src' => 'file.jpg')
  end

  def test_subject
    tr = Transformer.new File.read "#{__dir__}/pre.html"
    assert_equal "tesing pre newlines", tr.subject
    assert_equal "tesing pre newlines", tr.subject # memoization
  end
end
