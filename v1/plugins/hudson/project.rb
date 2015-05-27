require 'uri'

class Hudson
  class Project
    attr_reader :org, :repo

    def initialize(url)
      if url.present?
        @uri = URI.parse(url)
        @org, @repo = @uri.path.match(/(\w+)\/(\w+)/).captures
      end
    end


    def to_s
      [@org, @repo].compact.join('/')
    end
  end
end
