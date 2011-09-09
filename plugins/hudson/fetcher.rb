class Hudson
   class Fetcher < Typhoeus::Request
    BASE_URL = "https://hudson.3scale.net"
    JOB_URL = "/job/<project>/<test_run>/consoleText"

    attr_reader :test_run

    def initialize test_run, options = {}
      @test_run = test_run

      url = (BASE_URL + JOB_URL).
        gsub('<project>', test_run.project.to_s).
        gsub('<test_run>', test_run.number.to_s)

      super(url, options)

      fetcher.authorize = {
        :username => user,
        :password => pass
      } if user = ENV['HUDSON_USER'] && pass = ENV['HUDSON_PASS']

    end

    def authorize= options
      @username = options[:username]
      @password = options[:password]
    end

    def run
      HYDRA.queue self
      HYDRA.run
      self.response
    end
  end

end
