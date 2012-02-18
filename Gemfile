source :rubygems

#gem 'cinch'
# last gem relase is really outdated
gem 'cinch', :git => 'https://github.com/cinchrb/cinch.git'

gem 'rake', :require => false
gem 'activesupport', :require => 'active_support/core_ext'
gem 'i18n'

# debugging
group :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'awesome_print'
end

# Redis stuff
gem 'redis'
gem 'hiredis'
gem 'redis-namespace'
gem 'redis-objects', :require => 'redis/objects'

# http stuff
gem 'typhoeus'

# issues stuff
gem 'github_api'

gem 'json'

group :test do
  gem 'rspec'
  gem 'fakefs', :require => 'fakefs/safe'
end
