module October
  module Plugin
    class Github
      include October::Plugin

      match /\s(\w+): (\{.+\})$/, prefix: 'github event'

      def execute(m, event, payload)
        handler = "handle_#{event}"

        if respond_to?(handler)
          public_send(handler, payload)
        else
          @bot.loggers.debug  "[plugin] #{self.class.plugin_name}: no handler for #{event}"
        end
      end

      def handle_deployment_status(payload)
        info = JSON.parse(payload)
        channel.send "Hah, deployed!"
      end

      protected

      def channel
        name = config['channel'] || shared['github']
        Channel(name)
      end
    end
  end
end
