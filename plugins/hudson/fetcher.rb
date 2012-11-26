require 'httpclient'
require 'httpclient/include_client'

class Hudson
  class Fetcher
    class HTTPError < StandardError
      def initialize(response)
        message = "Failed to fetch #{response.http_header.request_uri} status:#{response.status} reason:#{response.reason}"
        super(message)
      end
    end

    extend HTTPClient::IncludeClient
    include_http_client do |client|
      user = ENV['HUDSON_USER'].presence
      pass = ENV['HUDSON_PASS'].presence

      if user or pass
        client.set_auth base_url, user, pass
      end
    end

    class_attribute :base_url, :job_url

    self.base_url = "http://localhost:8080"
    self.job_url  = "/job/<project>/<test_run>/consoleText"

    delegate :base_url, :job_url, :to => 'self.class'

    attr_reader :test_run, :url

    def initialize test_run, options = {}
      @test_run = test_run

      @url = (base_url + job_url).
        gsub('<project>', test_run.project.to_s).
        gsub('<test_run>', test_run.number.to_s).freeze
    end

    def response
      @response ||= self.class.http_client.get(url).tap do |response|
        unless response.ok?
          raise HTTPError, response
        end
      end
    end
  end
end
