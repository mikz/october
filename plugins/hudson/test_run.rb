class Hudson
  class TestRun

    CUCUMBERS = /^cucumber (?:.+?\/)(features\/.+?\.feature:\d+)/

    TEST_UNIT = /\d+\) (?:Failure|Error):\n(.+?)(?:\n{2})/m
    TEST_UNIT_NAME = /(.+)\((.+)\)[\n: ]+/
    TEST_UNIT_FILES = /(?:(test\/.+.[a-z]+):\d+)+(?::in `.+')?/

    attr_reader :project, :number

    def initialize(project, number = nil)
      @project = project
      @number = number.presence || 'lastBuild'

      @fetcher = Fetcher.new self
    end

    def cucumbers
      @cucumbers ||= parse_cucumbers
    end

    def test_unit
      @test_unit ||= parse_test_unit
    end

    delegate :response, :to => :@fetcher

    def log
      response.body
    end


    private
    def parse_cucumbers
      failures = self.log.scan(CUCUMBERS)
      failures.uniq!
      failures
    end

    def parse_test_unit
      blocks = self.log.scan(TEST_UNIT).flatten

      blocks.map! do |block|
        [
          block.scan(TEST_UNIT_NAME).first.first,
          block.scan(TEST_UNIT_FILES).last
        ].flatten
      end

      blocks
    end
  end
end
