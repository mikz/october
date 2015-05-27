module October
  module Plugin
    autoload :Help, 'october/plugin/help'

    def self.included(base)
      base.include(Cinch::Plugin)
      base.extend(ClassMethods)
    end

    @@help = {}

    def self.help
      @@help
    end

    module ClassMethods
      def register_help(command, description = ni)
        October::Plugin.help[command] = description
      end

      def registered_help
        October::Plugin.help
      end
    end
  end
end
