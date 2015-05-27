require 'active_support/concern'
require 'cinch'

module October
  module Plugin
    autoload :Help, 'october/plugin/help'

    extend ActiveSupport::Concern

    included do
      include Cinch::Plugin
      extend Help
    end

    module ClassMethods
      def name
        to_s.underscore
      end

      def config
        October::Plugins.config(name)
      end
    end

  end
end
