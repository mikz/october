module October
  module Plugin

    extend ActiveSupport::Concern

    included do
      self.send :include, Cinch::Plugin
    end

  end
end
