module October
  module Config
    extend Environment
    def load_config!
      env = Config.configuration('irc.yml')
      return unless env.present?

      env.each_pair do |key, value|
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
