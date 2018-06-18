# frozen_string_literal: true

module BotContext
  class Socket
    attr_reader :data

    def initialize(url, options)
      @url = url
      @options = options
      @data = []
    end

    def start_async(client)
      client.run_loop
    end

    def connect!
      @connected = true
    end

    def connected?
      @connected
    end

    def send_data(json)
      data = JSON.parse(json)
      @data << data
      data
    end
  end
end

RSpec.shared_context :bot do
  let(:shared_config) { {} }
  let(:bot) { October::Bot.new(concurrency: BotContext, shared: shared_config) }
end
