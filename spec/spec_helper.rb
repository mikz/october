$:.unshift File.expand_path('.') # root
$:.unshift File.dirname(__FILE__) # spec folder

ENV['OCTOBER_ENV'] ||= 'test'

require 'boot'
require 'october'

Dir['spec/helpers/**/*.rb'].each do |helper|
  require helper
end
