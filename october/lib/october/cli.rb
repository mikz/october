require 'thor'

require 'october'

require 'october/plugin/github'

module October
  class CLI < Thor

    desc 'start', 'start irc both and web server'
    method_option :port, type: :numeric, default: 6767

    def start
      app = new_app
      bot = app.bot

      server = Rack::Server.new(app: app)

      bot.in_thread { start }

      server.start
    end

    desc 'console', 'start console with loaded bot and server'
    def console
      require 'pry'

      binding = Pry.toplevel_binding

      app = new_app
      bot = app.bot
      server = Rack::Server.new(app: app)

      binding.receiver.extend(ConsoleMethods)

      set_sticky_variables = -> (output, binding, pry) do
        pry.add_sticky_local(:bot) { bot }
        pry.add_sticky_local(:app) { app }
        pry.add_sticky_local(:server) { server }
      end

      Pry.start(binding, hooks: { before_session: set_sticky_variables })
    end

    desc 'server', 'start web server'
    def server
      October::Server.start
    end


    private

    def new_app
      bot = new_bot

      app = October::Server.dup
      app.bot = bot

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
      options.map{|k, v| [k.to_sym, v] }.to_h
    end
  end
end
