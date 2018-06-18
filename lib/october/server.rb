# frozen_string_literal: true

require 'rack'
require 'roda'

module October
  class Server < Roda
    plugin :multi_run

    # @param [::October::Bot>] bot
    def self.bot=(bot)
      opts[:bot] = bot
    end

    # @return [nil, ::October::Bot]
    def self.bot
      opts[:bot]
    end

    route do |r|
      bot = env['october.bot'] = opts[:bot]

      # as the bot might be started after booting the server
      r.class.refresh_multi_run_regexp!

      r.multi_run do |prefix|
        env['october.plugin'] = bot.plugins[prefix]
      end
    end
  end
end
