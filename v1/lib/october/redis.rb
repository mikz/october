require 'redis'
require 'hiredis'
require 'active_support/core_ext/hash/keys'

module October
  module Redis
    extend Environment

    def self.included(base)
      base.extend(ClassMethods)

      return unless config

      # FIXME: parhaps more options, fetch from redis directly, or pass them all and let redis to handle it?
      redis = ::Redis.new(config)
      Ohm.connect(config)

      if namespace = config[:namespace]
        redis = ::Redis::Namespace.new namespace, :redis => redis
      end
      redis.incr 'launches'
      $redis = redis
    end

    def self.config
      return unless @@config = Redis.configuration('redis.yml')
      @@config.slice(:host, :port, :path, :db, :url, :thread_safe)
    end

    module ClassMethods
      def redis
        October::Redis
      end
    end
  end
end
