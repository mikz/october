require 'slack-ruby-client'

module October
  class Bot

    attr_reader :client

    def initialize(token: nil, concurrency: nil, plugins: nil, shared: nil)
      @client = Slack::RealTime::Client.new(token: token,
                                            concurrency: concurrency)

      @plugins_config = plugins
    end

    def start
      register_plugins

      client.async_start
    end

    def register_plugins
      @plugins = @plugins_config.fetch(:plugins).map{ |plugin| plugin.new(self) }
    end

    def register_matcher(matcher)
      client.on(matcher.type, &matcher)
    end

    def self.available_options
      %i[token concurrency plugins shared]
    end
  end
end
