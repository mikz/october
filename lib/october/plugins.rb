module October
  class Plugins < Array
    extend Environment

    attr_reader :loaded

    def initialize
      @loaded = []
      import Plugins.configuration('plugins.yml')
    end

    def registered
      self.class.registered
    end

    def import names
      names.map!{ |name| name.classify }
      diff = registered.keys & (names - self)
      push *diff
      load diff
    end

    def imported
      self
    end


    def load new
      @loaded.push *new.map{ |plugin|
        require registered[plugin]
        plugin.constantize
      }
    end

    module PluginMethods
      extend ActiveSupport::Concern

      included do
        attr_reader :plugin_module
      end

      def initialize
        plugins = Plugins.new
        super
        # stupid, really, why so long?
        self.config.plugins.plugins.push *plugins.loaded
      end

    end

    class << self

      @@plugins = {}

      def initialize
        October.root.join('plugins').
          each_child(false).
            each do |child|
              next unless child.to_s =~ /\.rb$/
              name = child.basename('.rb').to_s.classify
              register name => child
            end

        PluginMethods
      end

      def register plugin
        @@plugins.merge! plugin
      end

      def registered
        @@plugins
      end

    end

  end
end
