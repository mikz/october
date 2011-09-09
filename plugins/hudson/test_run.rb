class Hudson
  class TestRun

    FAILURE = /^cucumber (?:.+?\/)(features\/.+?\.feature:\d+)/

    attr_reader :project, :number

    def initialize(project, number)
      @project = project
      @number = number

      @fetcher = Fetcher.new self
    end

    def failures
      @failures ||= parse_failures
    end

    def some

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
