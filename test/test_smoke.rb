require_relative '../lib'
require 'minitest/autorun'

class TestMeme < Minitest::Test
  def test_local_img
    refute Transformer.local_img?('src' => "http://example.com")
    refute Transformer.local_img?('src' => '')
    refute Transformer.local_img?({})
    assert Transformer.local_img?('src' => 'file.jpg')
  end
end
