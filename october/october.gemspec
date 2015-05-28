# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'october/version'

Gem::Specification.new do |spec|
  spec.name          = 'october'
  spec.version       = October::VERSION
  spec.authors       = ['Michal Cichra']
  spec.email         = ['michal.cichra@gmail.com']

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/mikz/october'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb'] + Dir['exe/**/*'] + %w[README.md LICENSE.txt Rakefile]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_development_dependency 'rspec', '~> 3.2'

  spec.add_dependency 'cinch', '~> 2.2.5'
  spec.add_dependency 'thor'
end
