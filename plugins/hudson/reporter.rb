class Hudson
  class Reporter

    attr_reader :tests

    def initialize *tests
      @tests = tests
    end

    def report
      @tests.map do |test|
        [
          "------- #{test.project}/#{test.number} -------",
          test.failures
        ]
      end.flatten.join("\n")
    end

    def diff
      diff = failures.last[:failures].count - failures.first[:failures].count
      msg = %{
        Difference is: #{diff.abs} failures #{count < 0 ? 'less' : 'more'} in second test.
        Failures only in first:
        #{(failures.last[:failures] - failures.first[:failures]).join("\n")}
        Failures only in second:
        #{(failures.first[:failures] - failures.last[:failures]).join("\n")}
      }
    end

    def respond format, message

      if responses.all? &:success?
        return message.user.msg self.send(format)
      end

      responses(&:timed_out?).each do |r|
        message.reply 'Some requests timed out :('
      end

      responses{|r| r.code == 0 }.each do |r|
        message.reply r.curl_error_message
      end

      responses{|r| r.code != 200 }.each do |r|
        message.reply "HTTP request failed: #{r.code}"
      end

    end

    private

    def responses(&block)
      @tests.map(&:response).select &block
    end

  end
end
