# frozen_string_literal: true

module October
  module Thread
    def in_thread(&block)
      ::Thread.new do
        instance_exec(&block)
      end
    end
  end
end
