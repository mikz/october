module October
  module Environment
    class NoSuchEnvironment < StandardError; end

    def load_configuration(file)
      config = File.join('config', file)
      return {} unless File.exists?(config)
      YAML.load_file( config ).with_indifferent_access
    end

    def environment
       ENV['OCTOBER_ENV'].presence || 'default'
    end

    def configuration(file, env = environment)
      load_configuration(file)[env.to_sym]
    end

    def configuration!(file, env = environment)
      configuration(file, env) or raise NoSuchEnvironment.new("No environment #{env} in file #{file}")
    end

  end
end
