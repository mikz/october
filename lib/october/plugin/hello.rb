module October
  module Plugin
    class Hello
      include October::Plugin

      match 'hello'

      on :hello, method: :hello

      def execute(m)
        client.reply_with "Hi <@#{m.user}>!", to: m
      end

      def hello(m)
        client.typing '#octobot'
      end
    end
  end
end
