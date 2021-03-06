# frozen_string_literal: true

require 'october/plugin'

module October
  module Plugin
    class Help
      include October::Plugin
      register_help 'help', 'list all registered commands with description'

      match 'help', method: :help

      def help(m)
        msg = ['October help:', list_help].join("\n")
        client.reply_with msg, to: m
      end

      protected

      def list_help
        October::Plugin.help.map do |command, description|
          ['  !', [command, description].compact.join(' - ')].join
        end.join("\n")
      end
    end
  end
end
