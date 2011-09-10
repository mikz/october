module October
  module Plugin
    autoload :Help, 'october/plugin/help'

    extend ActiveSupport::Concern

    included do
      self.send :include, Cinch::Plugin
      self.send :extend, Help
    end

  end
end
