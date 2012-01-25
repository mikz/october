class Hudson
  class TestRun

    class Cucumber
      PATTERN = /^cucumber (?:.+?\/)(features\/.+?\.feature:\d+)/

      def self.parse(log)
        log.scan(PATTERN).flatten.uniq.map{ |name| self.new(name) }
      end

      def initialize(file)
        @file = file
      end

      def to_s
        @file
      end

      def ==(other)
        to_s == other.try(:to_s)
      end
    end

    class TestUnit
      PATTERN = /\d+\) (?:Failure|Error):\n(.+?)(?:\n{2})/m
      NAME = /(.+)\((.+)\)[\n: ]+/
      FILE = /(?:(test\/.+.[a-z]+):\d+)+(?::in `.+')?/

      def self.parse(log)
        blocks = log.scan(PATTERN).flatten
        blocks.map do |block|
          name = block.scan(NAME).first.first
          file = block.scan(FILE).last.last
          self.new(name, file)
        end
      end

      def initialize(name, file)
        @name, @file = name, file
      end

      def to_s
        "#{@file} -n '#{@name}'"
      end

      def ==(other)
        to_s == other.try(:to_s)
      end
    end


    attr_reader :project, :number

    def initialize(project, number = nil)
      @project = project
      @number = number.presence || 'lastBuild'

      @fetcher = Fetcher.new self
    end

    def cucumbers
      @cucumbers ||= Cucumber.parse(log)
    end

    def test_unit
      @test_unit ||= TestUnit.parse(log)
    end

    def all
      cucumbers + test_unit
    end

    alias :failures :all

    delegate :response, :to => :@fetcher

    def log
      response.body
    end

  end
end
