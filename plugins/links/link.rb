class Links
  class Link
    include Redis::Objects
    value 'url'
    hash_key 'metadata'

    attr_reader :id

    def initialize id
      @id = id
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

    class << self

      def find id
        Link.new(id)
      end

      def list scope
        ids = $redis.smembers "links:#{scope}"
        ids.map { |id| Link.find(id) }
      end

      def create(url, scope, metadata = {})
        metadata.reverse_merge! :timestamp => Time.now
        metadata.symbolize_keys!
        metadata.select!{ |k,v| v.present? }


        id = $redis.incr 'links'
        link = Link.new(id)

        link.url = url
        link.metadata.bulk_set metadata
        $redis.sadd "links:#{scope}", id
        link
      end

     end
  end
end
