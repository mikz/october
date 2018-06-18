require 'october/client'

module October
  class Bot

    attr_reader :client
    attr_reader :logger
    attr_reader :plugins, :plugins_config, :shared_config

    def initialize(token: nil, concurrency: nil, plugins: nil, shared: nil, logger: nil)
      @logger = logger || Logger.new($stdout)
      @shared_config = (shared || {}).freeze
      @plugins_config = (plugins || {}).freeze
      @client = October::Client.new(token: token, concurrency: concurrency, logger: @logger)
    end

    def start
      register_plugins
      client.start
    end

    def register_plugins
      @plugins = @plugins_config.fetch(:plugins)
          .map{ |plugin| plugin.supervise(as: plugin.plugin_name, args: [self]) }
          .flat_map(&:actors).uniq.each(&:__register)
          .map{ |plugin| [ plugin.class.plugin_name, plugin ] }.to_h.freeze
    end

    def register_matcher(matcher)
      client.add_matcher(matcher)
    end

    def self.available_options
      %i[config token concurrency plugins shared]
    end
  end
end
