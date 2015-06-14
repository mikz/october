require 'thor'

require 'october'

require 'october/plugin/github_webhooks'

module October
  class CLI < Thor

    desc 'start', 'start irc both and web server'
    method_option :port, type: :numeric, default: 6667
    method_option :listen, type: :numeric, default: 8080

    def start
      app, bot = boot

      server = Rack::Server.new(app: app, Port: options[:listen])

      bot.in_thread { start }

      server.start
    end

    desc 'console', 'start console with loaded bot and server'
    def console
      require 'pry'

      binding = Pry.toplevel_binding

      app, bot = boot

      server = Rack::Server.new(app: app)

      binding.receiver.extend(ConsoleMethods)

      set_sticky_variables = -> (output, binding, pry) do
        pry.add_sticky_local(:bot) { bot }
        pry.add_sticky_local(:app) { app }
        pry.add_sticky_local(:server) { server }
      end

      Pry.start(binding, hooks: { before_session: set_sticky_variables })
    end

    private

    def boot

      bot = new_bot
      app = new_app

      puts app.multi_run_apps
      puts October::Server.multi_run_apps
      app.bot = bot

      [app, bot]
    end

    def new_app
      app = October::Server.dup
      app
    end

    def new_bot
      bot = October::Bot.new
      bot.config.load(configuration)
      bot
    end

    module ConsoleMethods
      def reload!
        Object.send(:remove_const, :October) rescue nil
        $LOADED_FEATURES.reject! { |f| f.start_with?(Dir.pwd) }
        require 'october'
      end
    end

    def configuration
      {
          port: options[:port],
          plugins: { plugins: [ October::Plugin::Github ]}
      }
    end
  end
end
