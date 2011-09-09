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
      if response.success?
        message.user.msg content.call
      elsif response.timed_out?
        # aw hell no
        message.reply("got a time out")
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        message.reply(response.curl_error_message)
      else
        # Received a non-successful http response.
        message.reply("HTTP request failed: " + response.code.to_s)
      end
    end

  end
end
