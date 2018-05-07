require_relative '../podgraph'
require 'minitest/autorun'

include Podgraph

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

    tr = Transformer.new '<p>1</p>'
    assert_equal "no subject", tr.subject
  end

  def test_pre
    skip
    tr = Transformer.new "<!doctype html><pre><code>  1\n\n  2</code></pre>"
    assert_equal "<!DOCTYPE html>\n<html><body><pre><code>&nbsp;1&nbsp;<br><br>&nbsp;&nbsp;2</code></pre></body></html>\n", tr.html
  end

  def test_svg
    tr = Transformer.new "<!doctype html><p>1<img src='#{__dir__}/circle.svg'></p>"
    assert_equal "<!DOCTYPE html>
<html><body><p>1<img src=\"data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+CjxzdmcgdmVyc2lvbj0iMS4xIiB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSIxMDAiIHI9IjgwIiBmaWxsPSJibHVlIiAvPgogIDx0ZXh0IHg9IjEwMCIgeT0iMTI1IiBmb250LXNpemU9IjYwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSJ5ZWxsb3ciPlNWRzwvdGV4dD4KPC9zdmc+Cg==\"></p></body></html>
", tr.html
  end

  def test_raster_images
    tr = Transformer.new "<!doctype html><img src='#{__dir__}/red.gif'><img src='#{__dir__}/red.gif"
    assert_equal "<!DOCTYPE html>
<html><body>
<img src=\"cid:642a8e0e068af068d844962c2e0f9af7c73b798e\"><img src=\"cid:642a8e0e068af068d844962c2e0f9af7c73b798e\">
</body></html>
", tr.html
    assert_equal({"642a8e0e068af068d844962c2e0f9af7c73b798e" => {
                    :name => "#{__dir__}/red.gif"
                  }}, tr.images)
  end
end
