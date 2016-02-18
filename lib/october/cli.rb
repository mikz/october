require 'thor'

begin
require 'pry'
rescue LoadError
end

require 'october'

require 'october/plugin/github'
require 'october/plugin/github_webhooks'

module October
  class CLI < Thor

    desc 'start', 'start irc both and web server'
    method_option :token, type: :string, required: true
    method_option :channels, type: :array
    method_option :listen, type: :numeric, default: 8080
    method_option :config, type: :hash

    def start
      app, bot = boot

      server = Rack::Server.new(app: app, Port: options[:listen])

      bot.start

      server.start
    end

    desc 'console', 'start console with loaded bot and server'
    method_option :token, type: :string, required: false
    def console
      require 'pry'

      binding = Pry.toplevel_binding

      app, bot = boot

      server = Rack::Server.new(app: app)

      binding.receiver.extend(ConsoleMethods)

      set_sticky_variables = -> (_, _, pry) do
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
      bot = October::Bot.new(configuration)
      # bot.config.load(configuration)
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
      available = October::Bot.available_options

      values = options.values_at(*available)

      config = available.zip(values).select{ |(_, val)| val }.to_h

      plugins = {
          plugins: [
              October::Plugin::GithubWebhooks,
              October::Plugin::Github,
              October::Plugin::Hello,
          ]
      }

      shared = config.delete(:config)

      config.merge(plugins: plugins, shared: shared )
    end
  end
end
