module October
  module Config

    def configuration(name = ENV['OCTOBER_ENV'].presence || 'default')
      if @configuration ||= YAML.load_file(File.join('config', 'irc.yml'))
        @configuration
      end

      @configuration[name]
    end

    def load_config!
      configuration.each_pair do |key, value|
        config.send key.dup << '=', value
      end
    end

  end
end
