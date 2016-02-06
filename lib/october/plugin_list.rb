module October
  class PluginList
    def initialize(bot, plugins = [])
      @bot = bot
      @plugins = Array(plugins)
    end

    def [](name)
      @plugins.find{ |plugin| plugin.class.plugin_name == name }
    end

    # @param [Class<Plugin>] plugin
    def register_plugin(plugin)
      @plugins << plugin.new(@bot)
    end

    # @param [Array<Class<Plugin>>] plugins
    def register_plugins(plugins)
      plugins.each { |plugin| register_plugin(plugin) }
    end

    # @since 2.0.0
    def unregister_plugin(plugin)
      plugin.unregister
      @plugins.delete(plugin)
    end

    # @since 2.0.0
    def unregister_plugins(plugins)
      plugins.each { |plugin| unregister_plugin(plugin) }
    end

    # @since 2.0.0
    def unregister_all
      unregister_plugins(@plugins)
    end
  end
end
