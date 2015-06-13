require 'cinch/plugin'

module October
  module Plugin
    autoload :Help, 'october/plugin/help'

    def self.included(base)
      base.include(Cinch::Plugin)
      base.extend(ClassMethods)
      base.prepend(RegisterMethods)
    end

    @@help = {}

    def self.help
      @@help
    end

    module RegisterMethods
      def __register
        super
        __register_server
      end

      def __register_server

        self.class.mounts.each_pair do |prefix, app|
          @bot.loggers.debug "[plugin] #{self.class.plugin_name}: Registering prefix #{prefix} with web server #{app}"
          October::Server.run(prefix, app)
        end
      end

      private :__register_server
    end

    module ClassMethods
      def self.extended(mod)
        mod.instance_variable_set(:@mounts, {})
      end

      def register_help(command, description = nil)
        October::Plugin.help[command] = description
      end

      def registered_help
        October::Plugin.help
      end

      def mount(prefix, app)
        mounts[prefix] = app
      end

      def app(app)
        mount plugin_name, app
      end

      def mounts
        @mounts
      end
    end
  end
end
