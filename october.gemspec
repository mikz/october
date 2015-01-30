lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'october/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Michal Cichra"]
  gem.email         = ["mikz@o2h.cz"]
  gem.description   = %q{IRC Bot}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/mikz/october"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n") - %w{.gitignore .rvmrc .travis.yml Guardfile Gemfile.lock}
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "october"
  gem.require_paths = ["lib", "plugins"]
  gem.version       = October::VERSION

  gem.add_dependency 'activesupport'
  gem.add_dependency 'i18n'

  gem.add_dependency 'cinch', '~> 2.1.0'

  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'rspec-its'
  gem.add_development_dependency 'memfs'
end

