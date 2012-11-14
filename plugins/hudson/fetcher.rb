class Hudson
   class Fetcher < Typhoeus::Request
    BASE_URL = "http://localhost:8080"
    JOB_URL = "/job/<project>/<test_run>/consoleText"

    attr_reader :test_run

    def initialize test_run, options = {}
      @test_run = test_run

      url = (BASE_URL + JOB_URL).
        gsub('<project>', test_run.project.to_s).
        gsub('<test_run>', test_run.number.to_s)

      user = ENV['HUDSON_USER'].presence
      pass = ENV['HUDSON_PASS'].presence

      if user or pass
        options.reverse_merge!(
          :httpauth => :basic,
          :userpwd => [user, pass].join(':')
        )
      end

      super(url, options)
    end

    def response
      @response or run
    end

    def run
      HYDRA.queue self
      HYDRA.run
      self.response
    end
  end

end
