class Links
  class Link
    include Redis::Objects
    value 'url'
    hash_key 'metadata'

    attr_reader :id, :scope

    def initialize id, scope = nil
      @id = id
      @scope = scope.dup.freeze if scope
    end
    alias :meta :metadata

    def description
      meta[:description]
    end

    def user
      meta[:user]
    end

    def to_list
      %{#{id}) #{url} #{description} by #{user}}
    end

    def remove
      $redis.srem(scope, id)
    end

    class << self

      def find id, scope = nil
        if scope = links(scope)
          Link.new(id, scope) if $redis.sismember(scope, id)
        else
          Link.new(id)
        end
      end

      def list scope
        ids = $redis.smembers links(scope)
        ids.map { |id| Link.find(id) }
      end

      def links(scope)
        "links:#{scope}" if scope
      end

      def create(url, scope, metadata = {})
        metadata.reverse_merge! :timestamp => Time.now
        metadata.symbolize_keys!
        metadata.select!{ |k,v| v.present? }


        id = $redis.incr 'links'
        link = Link.new(id)

        link.url = url
        link.metadata.bulk_set metadata
        $redis.sadd links(scope), id
        link
      end


     end
  end
end
