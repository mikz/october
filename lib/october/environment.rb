module October
  module Environment
    class NoSuchEnvironment < StandardError; end

    def load_configuration(file)
      YAML.load_file( File.join 'config', file ).with_indifferent_access
    end

    def configuration(file, env = ENV['OCTOBER_ENV'].presence || 'default')
      load_configuration(file)[env.to_sym] or raise NoSuchEnvironment.new "No environment #{env} in file #{file}"
    end

  end
end
