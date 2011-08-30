module October
  module Config

    def configuration(name = ENV['OCTOBER_ENV'].presence || 'default')
      @configuration ||= YAML.load_file(File.join('config', 'irc.yml')).with_indifferent_access
      @configuration[name.to_sym]
    end

    def load_config!
      configuration.each_pair do |key, value|
        # FIXME: make DRY
        # FIXME: only one level - bad, only to support SSL nested values for now
        if value.is_a? Hash
          subconfig = config.send key.dup
          value.each_pair do |key, value|
            subconfig.send key.dup << '=', value
          end
        else
          config.send key.dup << '=', value
        end
      end
    end

  end
end
