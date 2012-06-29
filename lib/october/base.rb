require 'cinch'

module October
  class Base < Cinch::Bot

    def self.start
      new.start
    end

    include Config
    include Redis
    include Plugins.initialize

    def initialize
      super do
        load_config!

        on :message, "hello" do |m|
          m.reply "Hello, #{m.user.nick}"
        end

      end

    end

  end
end

