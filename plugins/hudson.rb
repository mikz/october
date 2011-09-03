gem 'typhoeus'

class Hudson
  include October::Plugin
  puts 'hudsion loaded'
  HYDRA = Typhoeus::Hydra.new
  FAILURE = /^cucumber (?:.+?\/)(features\/.+?\.feature:\d+)/

  class Fetcher < Typhoeus::Request
    BASE_URL = "https://hudson.3scale.net"
    JOB_URL = "/job/<project>/<test_run>/consoleText"

    attr_reader :project, :test_run

    def initialize project, test_run, options = {}
      @project = project
      @test_run = test_run

      url = (BASE_URL + JOB_URL).
        gsub('<project>', project.to_s).
        gsub('<test_run>', test_run.to_s)

      super(url, options)

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

  match /hudson failures (.+?)\/(\d+)/
  def parse_failures(log)
    log = log.split("\n").map do |line|
      line =~ FAILURE ? $1 : nil
    end
    log.compact!
    log.uniq!
    log.join("\n")
  end

  def execute(m, project, test_run)
    fetcher = Fetcher.new project, test_run
    fetcher.authorize = {
      :username => ENV['HUDSON_USER'],
      :password => ENV['HUDSON_PASS']
    }

    response = fetcher.run

    if response.success?
      failures = parse_failures(response.body)
      m.user.msg %{------- #{project}/#{test_run} -------\n} << failures
    elsif response.timed_out?
      # aw hell no
      m.reply("got a time out")
    elsif response.code == 0
      # Could not get an http response, something's wrong.
      m.reply(response.curl_error_message)
    else
      # Received a non-successful http response.
      m.reply("HTTP request failed: " + response.code.to_s)
    end
  end
end
