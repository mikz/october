require 'october/plugin'

module October
  module Plugin
    class Github
      include October::Plugin
      include Celluloid::Notifications

      def initialize(*)
        super # TODO: do not require plugin to have initialize, use attr accessors instead

        if (channel = shared['github'])
          subscribe(/^#{channel}/, :new_webhook)
        end
      end

      match /\s(\w+): (\{.+\})$/, prefix: 'github event'

      def execute(m, event, payload)
        handler = "handle_#{event}"

        if respond_to?(handler)
          public_send(handler, payload)
        else
          @bot.logger.debug  "[plugin] #{self.class.plugin_name}: no handler for #{event}"
        end
      end

      def handle_issues(*args)
        # slack message
      end

      def handle_deployment_status(payload)
        info = JSON.parse(payload)
        channel.send "Hah, deployed!"
      end

      def new_webhook(topic, event)
        # celluloid notification
      end

      protected

      def channel
        name = config['channel'] || shared['github']
        Channel(name)
      end
    end
  end
end
