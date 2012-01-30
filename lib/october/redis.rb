require 'redis'
require 'hiredis'
require 'active_support/core_ext/hash/keys'

module October
  module Redis
    extend Environment

    def self.included(base)
      return unless config = Redis.configuration('redis.yml')
      # FIXME: parhaps more options, fetch from redis directly, or pass them all and let redis to handle it?
      redis = ::Redis.new config.slice :host, :port, :path
      if config.has_key? :namespace
        redis = ::Redis::Namespace.new config[:namespace], :redis => redis
      end
      redis.incr 'launches'
      $redis = redis
    end
  end
end
