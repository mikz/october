$:.unshift File.dirname(__FILE__)

require 'boot'
require 'october'

task :create do
  end

task :start, :env, :console do |task, args|
    ENV['OCTOBER_ENV'] ||= args[:env].presence

    if args[:console]
      puts 'including debugger'
      Cinch::IRC.send :include, October::Debugger
    end

    @bot = October::Base.new
    @bot.start
end

task :console, :env do |task, args|
  Rake::Task['start'].invoke(args[:env], true)
end

task :default => :start
