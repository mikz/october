require 'github_api'

class Issues
  include October::Plugin

  prefix /^!issues? /
  register_help 'issue create title', 'create issue'
  register_help 'issue convert number head => base', 'convert issue to pull request'

  match /create (.+)$/, method: :create
  match /convert (\d+) (.+?)\s*=>\s*(.+)$/, method: :convert

  def create(m, text)
    Retryable.new(2) do |attempt|
      issue = api.issues.create_issue(nil, nil, IssueParser.new(text).to_hash)

      if issue
        m.reply "created issue #{issue.number} - #{issue.html_url}"

      elsif attempt < 2
        m.reply "issue wasn't created, retrying"
        false

      else
        m.reply "issue can't be created. sorry"
        false
      end
    end.run!
  rescue Github::UnprocessableEntity => e
    m.reply "Converting failed: "  + e.message
  end

  def convert(m, number, head, base)
    Retryable.new(2) do |attempt|
      pull = api.pull_requests.create_request nil, nil, :issue => number, :head => head, :base => base

      if pull
        m.reply "Simba, there is a new pull request! #{pull.html_url}"

      elsif attempt < 2
        m.reply "issue wasn't converted, retrying"
        false

      else
        m.reply "issue was not converted to pull request"
        false
      end
    end.run!
  rescue Github::UnprocessableEntity => e
    m.reply "Converting failed: "  + e.message
  end

  private

  def config
    self.class.config.symbolize_keys
  end

  def api
    @api ||= Github.new config
  end

  class Retryable
    attr_reader :attempts

    def initialize(attempts = 2, &block)
      @attempts = attempts
      @block = block
    end

    def run!
      attempts.times do |attempt|
        return if @block.call(attempt + 1)
      end
    end
  end

  class IssueParser
    def initialize(text)
      @text = text
    end

    def tokens
      @tokens ||= @text.split('|').map(&:strip)
    end

    def parse(name)
      [tokens.find{ |t| t =~ /^#{name}:\s*(.+)$/ }, $1]
    end

    def attr(name)
      parse(name).last
    end

    def token(name)
      parse(name).first
    end

    def milestone
      attr(:milestone)
    end

    def title
      tokens.first
    end

    def body
      except = [token(:milestone), token(/assigne{2}?/), title]
      tokens.find {|t| not except.include?(t) }
    end

    def assignee
      attr(/assigne{2}?/)
    end

    def to_hash
      {
        title: title,
        body: body,
        milestone: milestone,
        assignee: assignee
      }
    end
  end

end
