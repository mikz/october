module October
  module Plugin
    module Help
      @@help = {}

      def self.extended(base)
      end

      def register_help command, description = nil
        @@help[command] = description
      end

      def list_help
        @@help.map do |command, description|
          ["  !", [command, description].compact.join(' - ')].join
        end.join("\n")
      end
    end
  end
end
