require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

require_relative 'lib/podgraph/meta'
require_relative 'test/rake_git'

spec = Gem::Specification.new do |s|
  s.name = Podgraph::Meta::NAME
  s.version = Podgraph::Meta::VERSION
  s.summary = 'Creates a MIME mail from a XHTML source and delivers it to Posterous.com.'
  s.description = 'Adequately scans XHTML for local inline images and appends them to the mail.'
  s.author = Podgraph::Meta::AUTHOR
  s.email = Podgraph::Meta::EMAIL
  s.homepage = Podgraph::Meta::HOMEPAGE
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.files = git_ls('.')
  s.executables = [s.name]

  s.test_files = FileList['test/test_*.rb']
  s.rdoc_options << '-m' << 'Podgraph'
  
  s.add_dependency('mail', '>= 2.2.17')
end

Rake::GemPackageTask.new(spec).define

task default: [:repackage]

Rake::RDocTask.new('doc') do |rd|
  rd.main = "Podgraph"
  rd.rdoc_files.include("lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end
