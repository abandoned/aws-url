# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require File.expand_path('../lib/aws/url/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Hakan Ensari']
  gem.email         = ['hakan.ensari@papercavalier.com']
  gem.description   = %q{A minimum-viable URL builder for Amazon Web Services (AWS)}
  gem.summary       = %q{Signs an Amazon Web Services URL}
  gem.homepage      = 'https://github.com/hakanensari/aws-url'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'aws-url'
  gem.require_paths = ['lib']
  gem.version       = AWS::URL::VERSION

  gem.add_development_dependency 'rake',  '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.9'
end
