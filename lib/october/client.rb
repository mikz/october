# frozen_string_literal: true

require 'slack-ruby-client'

module October
  class Client
    attr_reader :client, :logger
    alias slack client
    private :client, :logger

    def initialize(token:, concurrency:, logger:)
      @logger = logger
      @client = Slack::RealTime::Client.new(token: token,
                                            concurrency: concurrency)
    end

    def add_matcher(matcher)
      client.on(matcher.type, &matcher)
    end

    def start
      logger.debug '[client] starting the client'
      client.start_async
    end

    def typing(channel)
      client.typing channel: channel
    end

    def reply_with(text, to:)
      typing(to.channel)
      message(text, to: to.channel)
    end

    def message(text, to:)
      client.message channel: to, text: text.to_s
    end

    NO_CHANNELS = {}.freeze

    def channels
      ChannelList.new(client.channels || NO_CHANNELS)
    end

    class ChannelList
      def initialize(channels)
        @channels = channels.map(&Channel)
      end

      def [](name)
        @channels.find { |channel| channel.name == name }
      end
    end

    class Channel
      def self.to_proc
        to_attributes = ->((_id, options)) { options.map { |k, v| [k.to_sym, v] }.to_h }
        ->(channel) { new(to_attributes.call(channel)) }
      end

      attr_reader :id, :name

      def initialize(id:, name:, **_rest)
        @id = id.freeze
        @name = name.freeze
      end

      def as_json(options = nil)
        id.as_json(options)
      end

      def to_s
        id
      end
    end
  end
end
