# frozen_string_literal: true

require 'rack/test'

module Rack
  module Test
    module MethodGenerator
      HTTP_METHODS = %I[get post put patch options head delete].freeze

      def self.eval(binding, &block)
        source_location = block.source_location

        HTTP_METHODS.each do |method|
          definition = yield method
          binding.eval(definition, *source_location)
        end
      end
    end

    module KeywordMethods
      MethodGenerator.eval(binding) do |method|
        <<-method
          def #{method}(uri, params: {}, env: {}, &block)
            super(uri, params, env, &block)
          end
        method
      end
    end

    module HeaderMethods
      CONTENT_TYPE = 'CONTENT_TYPE'
      include KeywordMethods

      MethodGenerator.eval(binding) do |method|
        <<-method
          def #{method}(uri, headers: {}, env: {}, **options, &block)
            env_headers = HeaderMethods.headers_to_env(headers)
            super(uri, env: env.merge(env_headers), **options, &block)
          end
        method
      end

      def self.headers_to_env(headers)
        headers.map do |key, value|
          env_key = key.upcase.tr('-', '_')
          env_key = 'HTTP_' + env_key unless CONTENT_TYPE == env_key
          [env_key, value]
        end.to_h
      end
    end
  end
end

RSpec.shared_context :rack do
  include Rack::Test::Methods
  include Rack::Test::HeaderMethods

  subject(:app) { described_class }
end
