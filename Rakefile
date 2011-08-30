$:.unshift File.dirname(__FILE__)

require 'boot'
require 'october'

task :start do
  @bot = October::Base.new
  @bot.start
end

task :console  => [:start] do
  # FIXME: will not get there.. need to use plugin with hook on :connect 
  @bot.pry
end

task :default => :start
