require 'cinch'

module October
  class Bot < ::Cinch::Bot
    include October::Thread

    def initialize(*)
      super
      @plugins = October::PluginList.new(self, @plugins)
      set_nick @config.nick
    end

    def self.available_options
      Cinch::Configuration::Bot::KnownOptions
    end

    def quit!
      @quitting = true
    end
  end
end
