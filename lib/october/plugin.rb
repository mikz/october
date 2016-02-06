require 'ostruct'
require 'celluloid/current'

module October
  module Plugin
    autoload :Help, 'october/plugin/help'
    autoload :Hello, 'october/plugin/hello'

    def self.included(base)
      base.include(Celluloid)
      base.extend(ClassMethods)
      base.prepend(RegisterMethods)
    end

    extend Forwardable

    attr_reader :bot
    def_delegators :bot, :client

    def initialize(bot)
      @bot = bot
      @matchers = self.class.matchers.map{ |matcher| bot.register_matcher(matcher.call(self)) }
    end

    def shared
      bot.shared_config
    end

    @@help = {}

    def self.help
      @@help
    end

    module RegisterMethods
      def __register
        super if defined?(super)
        __register_server
      end

      def __register_server
        self.class.mounts.each_pair do |prefix, app|
          prefix = prefix.respond_to?(:call) ? prefix.call : prefix
          @bot.logger.debug "[plugin] #{self.class.plugin_name}: Registering prefix #{prefix} with web server #{app}"
          October::Server.run(prefix, app)
        end
      end

      private :__register_server
    end

    module ClassMethods
      def self.extended(mod)
        mod.instance_variable_set(:@mounts, {})
        name = mod.plugin_name
        mod.singleton_class.instance_eval do
          attr_accessor :plugin_name, :mounts
        end
        mod.mounts = {}
        mod.plugin_name = name
      end

      def register_help(command, description = nil)
        October::Plugin.help[command] = description
      end

      def registered_help
        October::Plugin.help
      end

      def mount(prefix, app)
        mounts[prefix] = app
      end

      def app(app)
        mount method(:plugin_name), app
      end

      def plugin_name
        defined?(super) && super || begin
          path = name.to_s

          if (i = path.rindex('::'))
            path[(i+2)..-1]
          else
            path
          end
        end
      end

      def match(expression, **options)
        matchers << Matcher.new(expression: expression, **options)
      end

      def on(event, **options)
        matchers << Matcher.new(type: event, **options)
      end

      def matchers
        @matchers ||= Set.new
      end

      def mounts
        @mounts
      end
    end

    class Message < OpenStruct; end

    class Matcher
      attr_reader :type

      def initialize(expression: nil, prefix: nil, method: :execute, type: :message)
        @expression = expression
        @prefix = prefix
        @method = method
        @type = type
      end

      def to_proc
        public_send("#{type}_handler")
      end

      def call(object)
        MessageDelegator.new BoundMatcherDelegator.new(self, object)
      end

      class BoundMatcherDelegator < SimpleDelegator
        def initialize(matcher, object)
          super(matcher)
          @object = object
        end

        def to_proc
          -> (message) do
            method, args = super.call(message)

            return unless method

            m = @object.method(method)

            if m.arity == 1 || args.nil?
              m.call(message)
            elsif args.is_a?(Hash)
              m.call(message, **args)
            elsif args.is_a?(Array)
              m.call(message, *args)
            else
              fail "unknown handler format #{m} #{args}"
            end
          end
        end
      end

      class MessageDelegator < SimpleDelegator
        def to_proc
          -> (data) do
            message = Message.new(data)
            super.call(message)
          end
        end
      end

      def hello_handler
        -> (_message) do
          [@method]
        end
      end

      def message_handler
        -> (message) do
          text = message.text or return
          match = text.match(@expression) or return

          names = match.names
          captures = match.captures

          args = if names.size == captures.size
            names.map(&:to_sym).zip(captures).to_h
          else
            captures
          end

          [@method, args]
        end
      end
    end
  end
end
