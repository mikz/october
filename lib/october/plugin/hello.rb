module October
  module Plugin
    class Hello
      include October::Plugin

      match 'hello'

      on :hello, method: :hello

      def execute(m)
        client.typing channel: m.channel
        client.message channel: m.channel, text: "Hi <@#{m.user}>!"
      end

      def hello(m)
        client.typing channel: '#octobot'
      end
    end
  end
end
