Gem::Specification.new do |s|
  s.version = '1.0.1'

  s.name = 'podgraph'
  s.summary = "Post to Blogger or Wordpress via email; inline local images"
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/podgraph'
  s.license = 'MIT'
  s.files = [
    'podgraph',
    'podgraph.rb',
    'package.gemspec',
    'README.md',
  ]

  s.require_paths = ['.']
  s.bindir = '.'
  s.executables = ['podgraph']

  s.add_runtime_dependency 'mail', '~> 2.7.0'
  s.add_runtime_dependency 'nokogiri', '~> 1.8.2'

  s.required_ruby_version = '>= 2.3.0'

  s.post_install_message = <<~END
    *************************************************************************
    If you were using podgraph-0.x, please read
    #{s.homepage},
    for it's a different program now, totally incompatible w/ 0.x releases.
    *************************************************************************
  END
end
