# -*- ruby -*-

require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'

spec = Gem::Specification.new do |s|
  s.name = "podgraph"
  s.summary = 'Creates a MIME mail from a XHTML source and delivers it to Posterous.com.'
  s.version = '0.0.3'
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'http://github.com/gromnitsky/' + s.name
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9'
  s.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'test/**/*']
  s.executables = [s.name]
  s.has_rdoc = true
  s.test_files = FileList['test/test_*.rb']
  s.rdoc_options << '-m' << 'Podgraph'
  
  s.add_dependency('mail', '= 2.1.3')
  s.add_dependency('activesupport', '>= 3.0.0')
end

Rake::GemPackageTask.new(spec).define

task :default => %(repackage)

Rake::RDocTask.new('doc') do |rd|
  rd.main = "Podgraph"
  rd.rdoc_files.include("lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end
