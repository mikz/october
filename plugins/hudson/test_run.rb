class Hudson
  class TestRun

    class Cucumber
      PATTERN = /^cucumber (?:-p .+?+\s)?(?:.+?\/)?(features\/.+?\.feature:\d+)/

      def self.parse(log)
        log.scan(PATTERN).flatten.uniq.map{ |name| self.new(name) }
      end

      def initialize(file)
        @file = file
      end

      def to_s
        @file
      end
      alias :to_str :to_s

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
          file = block.scan(FILE).last.try(:join) || '(missing file)'
          self.new(name, file)
        end
      end

      def initialize(name, file)
        @name, @file = name, file
      end

      def to_s
        "#{@file} -n '#{@name}'"
      end
      alias :to_str :to_s

      def ==(other)
        to_s == other.try(:to_s)
      end
    end


    attr_reader :job, :number

    def initialize(job, number = nil)
      @job = job
      @number = number.presence || 'lastBuild'
    end

    def fetcher
      @fetcher = Fetcher.new(self)
    end

    def cucumbers
      @cucumbers ||= Cucumber.parse(log)
    end

    def test_unit
      @test_unit ||= TestUnit.parse(log)
    end

    def branch
      build[:branch]
    end

    def build
      @build_info ||= log.match(/Revision (?<sha>.+?) \(origin\/(?<branch>.+?)\)/)
    end

    def project_url
      @project_url ||= config.xpath('//com.coravy.hudson.plugins.github.GithubProjectProperty/projectUrl').text.strip
    end

    def project
      @project ||= Hudson::Project.new(project_url)
    end

    def sha
      build[:sha]
    end

    def all
      cucumbers + test_unit
    end

    alias :failures :all

    delegate :response, :config, :to => :fetcher

    def log
      response.body
    end

  end
end
