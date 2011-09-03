#require 'boot'

module October
  autoload :Config, 'october/config'
  autoload :Base, 'october/base'
  autoload :Environment, 'october/environment'
  autoload :Redis, 'october/redis'
  autoload :Debugger, 'october/debugger'
  autoload :Plugins, 'october/plugins'
  autoload :Plugin, 'october/plugin'

  def self.root
    Pathname.new('.').expand_path
  end
end

