source 'https://rubygems.org'

gemspec(development_group: :test)

gem 'activesupport', require: 'active_support/core_ext'
gem 'i18n'

# debugging
group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'awesome_print'
end

# Redis stuff
gem 'redis'
gem 'hiredis'
gem 'redis-namespace'
gem 'redis-objects', require: 'redis/objects'
gem 'ohm'

gem 'httpclient'

# issues stuff - https://github.com/peter-murach/github/
gem 'github_api'

gem 'json'
gem 'nokogiri'
gem 'curb'

group :test do
  gem 'webmock', require: false
  gem 'memfs', github: 'simonc/memfs' # not yet released file << io
end
