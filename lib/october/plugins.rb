module October
  module Plugins

    def self.initialize
      October.root.join('plugins').
        each_child(false).
          each do |child|
            next unless child.to_s =~ /\.rb$/
            name = child.basename('.rb').to_s
            autoload name.classify, child
          end
    end

    initialize
  end
end
