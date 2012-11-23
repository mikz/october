class Hudson
  class Reporter

    class Diff
      include Enumerable

      def initialize(base, other)
        @base, @other = base, other
      end

      def header
        "--- #{@base.project}/#{@base.number} <=> #{@other.project}/#{@other.number} ---"
      end

      def each(&block)
        failures.each(&block)
      end

      def to_s
        [header, *surplus, *common, *missing].join("\n")
      end

      delegate :length, :to => :all

      private
      def surplus
        prefix('+', @other.failures - @base.failures)
      end

      def missing
        prefix('-', @base.failures - @other.failures)
      end

      def all
        @failures ||= @base.failures | @other.failures
      end

      def common
        prefix(' ', @base.failures & @other.failures)
      end

      def prefix(str, array)
        array.map{ |line| str + " " << line }
      end

    end

    class Report < Array
      def initialize test
        @project, @number = test.project, test.number
        super(test.failures.flatten)
      end

      def header
        "------- #{@project}/#{@number} -------"
      end

      def to_s
        [header, *self].join("\n")
      end
    end

    attr_reader :tests

    def initialize *tests
      @tests = tests.flatten
    end

    def report
      Report.new(@tests.first)
    end

    def diff
      Diff.new(@tests.first, @tests.last)
    end

    def respond format, message

      if responses.all? &:ok?
        return message.user.msg self.send(format)
      end

      responses.each do |response|
        message.reply "HTTP request failed (#{response.status}) #{response.reason}"
      end
    end

    private

    def responses
      @responses ||= @tests.map(&:response)
    end

  end
end
