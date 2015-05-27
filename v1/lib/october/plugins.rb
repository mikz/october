module October
  class Plugins < Array
    extend Environment

    attr_reader :loaded

    def initialize
      @loaded = []
      import Plugins.configuration('plugins.yml')
    end

    delegate :registered, :configure, :to => :'self.class'

    def import plugins
      return unless plugins.present?

      plugins = Hash[ plugins.map {|plugin|
        plugin.respond_to?(:to_a) ? plugin.to_a.flatten(1) : [plugin, {}]
      }].with_indifferent_access

      names = plugins.keys.map {|name| name.camelize }

      diff = registered.keys & (names - self)
      push *diff
      load diff

      self.class.configure(plugins)
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
      @@configs = {}.with_indifferent_access

      def initialize
        October.root.join('plugins').
          each_child(false).
            each do |file|
              next unless file.to_s =~ /\.rb$/
              name = file.basename('.rb').to_s.camelize
              register name => file
            end

        PluginMethods
      end

      def register plugin
        @@plugins.merge! plugin
      end

      def config(plugin)
        @@configs.fetch(plugin, {})
      end

      def configure(plugin)
        @@configs.merge! plugin
      end

      def registered
        @@plugins
      end

    end

  end
end
