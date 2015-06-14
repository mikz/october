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
      bot = env['october.bot'.freeze] = opts[:bot]

      # as the bot might be started after booting the server
      r.class.refresh_multi_run_regexp!

      # TODO: this can be replaced by normal r.multi_run(&block)
      # when https://github.com/jeremyevans/roda/pull/32 is merged
      r.on r.class.multi_run_regexp do |prefix|
        env['october.plugin'.freeze] = bot.plugins[prefix]
        r.run r.scope.class.multi_run_apps[prefix]
      end
    end
  end
end
