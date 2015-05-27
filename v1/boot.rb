require 'bundler/setup'
Bundler.require *[:default, ENV['RACK_ENV'], ENV['OCTOBER_ENV']].compact

$:.unshift File.expand_path('lib')
$:.unshift File.expand_path('plugins')