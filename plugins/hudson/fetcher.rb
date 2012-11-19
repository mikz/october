class Hudson
  class Fetcher < Typhoeus::Request
    class_attribute :base_url, :job_url

    self.base_url = "http://localhost:8080"
    self.job_url  = "/job/<project>/<test_run>/consoleText"

    delegate :base_url, :job_url, :to => 'self.class'

    attr_reader :test_run

    def initialize test_run, options = {}
      @test_run = test_run

      url = (base_url + job_url).
        gsub('<project>', test_run.project.to_s).
        gsub('<test_run>', test_run.number.to_s)

      user = ENV['HUDSON_USER'].presence
      pass = ENV['HUDSON_PASS'].presence

      options.reverse_merge! method: :get

      if user or pass
        options.reverse_merge!(
          :httpauth => :basic,
          :userpwd => [user, pass].join(':')
        )
      end

      super(url, options)
    end

    def response
      super or run or super
    end
  end
end
