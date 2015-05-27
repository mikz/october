$:.unshift File.expand_path('.') # root
$:.unshift File.dirname(__FILE__) # spec folder

ENV['OCTOBER_ENV'] ||= 'test'

require 'boot'
require 'october'

Bundler.require :test, :development

Dir['spec/helpers/**/*.rb'].each do |helper|
  require helper
end

require 'webmock/rspec'
WebMock.disable_net_connect!

# temporal hack until https://github.com/simonc/memfs/issues/15 is fixed
MemFs::File.send(:define_method, :fs) { MemFs::File.send(:fs) }
