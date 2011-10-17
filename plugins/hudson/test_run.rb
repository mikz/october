class Hudson
  class TestRun

    FAILURE = /^cucumber (?:.+?\/)(features\/.+?\.feature:\d+)/

    attr_reader :project, :number

    def initialize(project, number = nil)
      @project = project
      @number = number.presence || 'lastBuild'

      @fetcher = Fetcher.new self
    end

    def failures
      @failures ||= parse_failures
    end

    delegate :response, :to => :@fetcher

    def log
      response.body
    end


    private
    def parse_failures
      failures = self.log.split("\n").map do |line|
        line =~ FAILURE ? $1 : nil
      end
      failures.compact!
      failures.uniq!
      failures
    end
  end
end
