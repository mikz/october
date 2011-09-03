gem 'pry'

module October
  module Debugger
    extend ActiveSupport::Concern
    ##
    # Extends capabilities of Cinch::IRC to
    # launch debugger after connecting and creating all threads
    #

    included do

      self.class_eval do
        if method_defined? :start
          alias_pry(:start)
        elsif method_defined? :connect
          alias_pry(:connect)
        else
          raise 'Unsupported version of Cinch'
        end
      end

    end

    module InstanceMethods
      def init_pry
        Thread.new do
          binding.pry
          Thread.pass
        end

      end
    end

    module ClassMethods
      def alias_pry(before)
        class_eval %{

          def #{before}_with_pry
            init_pry
            #{before}_without_pry
          end

          alias_method_chain :#{before}, :pry
        }
      end
    end


  end
end
