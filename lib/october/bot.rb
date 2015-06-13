require 'cinch'

module October
  class Bot < ::Cinch::Bot
    include October::Thread

    def quit!
      @quitting = true
    end

    module Overrides
      def initialize(*args, &block)
        super
        @plugins = October::PluginList.new(self, @plugins)
      end
    end

    prepend Overrides
  end
end
