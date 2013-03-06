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

FakeFS.activate!
FakeFS::FileSystem.clear
FakeFS::FileSystem.clone('spec')
