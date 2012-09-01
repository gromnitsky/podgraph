# :erb:
# Various staff for minitest. Include this file into your 'helper.rb'.

require 'fileutils'
include FileUtils

require_relative '../lib/podgraph/trestle'
include Podgraph

require 'minitest/autorun'

# Return the right directory for (probably executable) _c_.
def cmd(c)
  case File.basename(Dir.pwd)
  when Meta::NAME.downcase
    # test probably is executed from the Rakefile
    Dir.chdir('test')
  when 'test'
    # we are in the test directory, there is nothing special to do
  else
    # tests were invoked by 'gem check -t podgraph'
    begin
      Dir.chdir(Trestle.gem_libdir + '/../../test')
    rescue
      raise "running tests from '#{Dir.pwd}' isn't supported: #{$!}"
    end
  end

  '../bin/' + c
end

# Don't remove this: falsework/0.2.2/naive/2010-12-26T04:50:00+02:00
