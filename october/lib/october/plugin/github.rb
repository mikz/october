require 'october/plugin'
require 'roda'

module October
  module Plugin
    class Github
      include October::Plugin

      class Server < ::Roda

        route do |r|
          bot = env['october.bot']
          plugin = env['october.plugin']



        end

      end

      app Server.app
    end
  end
end
