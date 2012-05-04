require 'github_api'

class Issues
  include October::Plugin

  self.prefix = /^!issues? /
  register_help 'issue create title', 'create issue'
  register_help 'issue create title | body', 'create issue with body'
  register_help 'issue create title | milestone: 2', 'create issue for milestone'
  register_help 'issue create title | assign: someone', 'create assigned issue'
  register_help 'issue create title | assign: someone | body | milestone: 3', 'combined approach to create issue'
  register_help 'issue convert number head => base', 'convert issue to pull request'

  GIT = /[a-z0-9]{7}|[a-z0-9]{40}/
  match /create (.+)$/, method: :create
  match /convert (\d+) (.+?)\s*=>\s*(.+)$/, method: :convert
  match /(?:issue\s+)?#(\d+)/, method: :issue, use_prefix: false
  match /commit ([a-z0-9]{7}|[a-z0-9]{40})(?:[^a-z0-9]|$)/, method: :commit, use_prefix: false

  def create(m, text)
    issue = Retryable.do { api.issues.create_issue(nil, nil, IssueParser.new(text).by(m.user.nick).to_hash) }
    m.reply "created issue #{issue.number} - #{issue.html_url}"
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Creation failed: "  + e.message
  end

  def convert(m, number, head, base)
    pull = Retryable.do { api.pull_requests.create_request nil, nil, :issue => number, :head => head, :base => base }
    m.reply "Simba, there is a new pull request! #{pull.html_url}"
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Converting failed: "  + e.message
  end

  def issue(m, number)
    if issue = Retryable.do { api.issues.issue(api.user, api.repo, number) }
      m.reply "#{issue.html_url} - #{issue.title}"
    end
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Issue failed: "  + e.message
  end

  def commit(m, rev)
    commit = Retryable.do { api.git_data.commit nil, nil, rev }
    m.reply "https://github.com/#{api.user}/#{api.repo}/commit/#{commit.sha} by #{commit.author.name}"
  rescue Github::Error::ResourceNotFound
    m.user.msg "sorry, but commit #{rev} was not found"
  end

  def comment(m, number, message)
    Retryable.do { api.issues.create_comment(api.user, api.repo, number, "body" => message)}
  rescue Github::Error::ResourceNotFound
    m.user.msg "sorry, but an error occurred while posting your comment"
  end

  # this method is used by the hudson plugin to figure out if a branch matches a pull request
  def pull_request(m, branch_name)
     pulls = Retryable.do { api.pull_requests.pull_requests(api.user, api.repo)}
     pulls.detect do |pr|
       full_pr = Retryable.do { api.pull_requests.pull_request(api.user, api.repo, pr["number"]) }
       return full_pr if full_pr["head"]["ref"] == branch_name
     end
     nil
  rescue Github::Error::ResourceNotFound
    m.user.msg "sorry, but an error occurred while fetching your pull request"
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
        value = @block.call(attempt + 1)
        return value if value
      end
    end

    def self.do &block
      new(&block).run!
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

    def by(user)
      @user = user
      self
    end

    def body
      except = [token(:milestone), token(/assigne{2}?/), title]
      tokens.find {|t| not except.include?(t) }
    end

    def assignee
      attr(/assigne{2}?/)
    end

    def to_hash(user = @user)
      text = body ? body.dup : ""
      text += "\nrequested by: #{user}" if user
      {
        title: title,
        body: text,
        milestone: milestone,
        assignee: assignee
      }
    end
  end

end
