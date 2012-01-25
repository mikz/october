task :integrate do |task|
  ENV['OCTOBER_ENV'] ||= 'test'

  %w{redis.yml irc.yml plugins.yml}.each do |file|
    File.open("config/#{file}", 'w') {|f| f.write("test:\n\tnothing: true") }
  end

  exec 'rspec spec'
end

task :environment, :env do |task, args|
  ENV['OCTOBER_ENV'] ||= args[:env]

  $:.unshift File.dirname(__FILE__)

  require 'boot'
  require 'october'

end

task :boot, [:env, :console] => :environment do |task, args|
  @bot = October::Base.new
end

desc 'Starts IRC server'
task :start, [:env, :console] => :boot do |task, args|
  if args[:console]
    Cinch::IRC.send :include, October::Debugger
  end

  @bot.start
end

desc 'Creates interactive console with Pry'
task :console, [:env] => :boot do |task, args|
  @bot.pry
end

#task :default => :start
