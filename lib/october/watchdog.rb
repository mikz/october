module October
  class Watchdog
    attr_reader :child, :root, :env

    def initialize(root, env = nil)
      @root = root
      @env = env
    end

    def spawn!
      @child = fork do
        ENV['OCTOBER_ENV'] ||= env

        require File.join(root, "boot")
        require 'october'

        @bot = October::Base.new
        @bot.start
      end
    end

    def loop!
      loop do
        begin
          Process.wait(spawn!)
          warn "process #{child} ended"
        rescue Errno::ECHILD
          warn "process #{child} died or was killed"
        end

        warn "spawning new one in next iteration"

        sleep(1) # throttle spawning in case anything fails
      end
    end
  end
end