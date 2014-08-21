require 'github_api'

class Issues
  include October::Plugin
  DEFAULT_BASE = :master

  self.prefix = /^!issues? /
  register_help 'issue create title', 'create issue'
  register_help 'issue create title | body', 'create issue with body'
  register_help 'issue create title | milestone: 2', 'create issue for milestone'
  register_help 'issue create title | assign: someone', 'create assigned issue'
  register_help 'issue create title | assign: someone | body | milestone: 3', 'combined approach to create issue'
  register_help 'issue convert number head => base', 'convert issue to pull request'
  register_help 'pull head => base', 'creates a new pull request'
  register_help 'register', 'send you oauth request url'
  register_help 'register login code', 'gives you token and registers that token in db so it can do stuff as you'

  GIT = /[a-z0-9]{7}|[a-z0-9]{40}/
  match /create (.+)$/, method: :create
  match /convert (\d+) (.+?)(?:\s*=>\s*(.+))?$/, method: :convert
  match /(?:issue\s+)?#(\d+)/, method: :issue, use_prefix: false
  match /commit ([a-z0-9]{7}|[a-z0-9]{40})(?:[^a-z0-9]|$)/, method: :commit, use_prefix: false
  match /\A!pull (.+?)(?:\s*=>\s*(.+))?$/, method: :pull, use_prefix: false

  match /\A!register(?:\s+(\w+)\s+(\w+))?/, method: :register, use_prefix: false

  def create(m, text)
    issue = Retryable.do { api(m).issues.create(api.user, api.repo, IssueParser.new(text).by(m.user.nick).to_hash) }
    m.reply "created issue #{issue.number} - #{issue.html_url}"
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Creation failed: "  + e.message
  end

  def pull(m, head, base = nil)
    base ||= DEFAULT_BASE
    pull = Retryable.do { api.pull_requests.create(api.user, api.repo, :head => head, :base => base, :title => head) }
    m.reply "Simba, there is a new pull request! #{pull.html_url}"
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Creation failed: "  + e.message
  end

  def convert(m, number, head, base = nil)
    base ||= DEFAULT_BASE
    pull = Retryable.do { api(m).pull_requests.create api.user, api.repo, :issue => number, :head => head, :base => base }
    m.reply "Simba, there is a new pull request! #{pull.html_url}"
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Converting failed: "  + e.message
  end

  def issue(m, number)
    return if m.user.nick == 'github'
    if issue = Retryable.do { api.issues.find(api.user, api.repo, number) }
      m.reply "#{issue.html_url} - #{issue.title}"
    end
  rescue Github::Error::UnprocessableEntity => e
    m.user.msg "Issue failed: "  + e.message
  end

  def commit(m, rev)
    commit = Retryable.do { api.git_data.commit api.user, api.repo, rev }
    m.reply "https://github.com/#{api.user}/#{api.repo}/commit/#{commit.sha} by #{commit.author.name}"
  rescue Github::Error::ResourceNotFound
    m.user.msg "sorry, but commit #{rev} was not found"
  end

  def comment(m, number, message)
    Retryable.do { api.issues.comments.create(api.user, api.repo, number, "body" => message)}
  rescue Github::Error::ResourceNotFound
    m.user.msg "sorry, but an error occurred while posting your comment"
  end

  # this method is used by the hudson plugin to figure out if a branch matches a pull request
  def pull_request(branch_name, m = nil)
     Retryable.do { api.pull_requests.list(api.user, api.repo) }.find { |pr| pr["head"]["ref"] == branch_name }
  rescue Github::Error::ResourceNotFound
    if m
      m.user.msg "sorry, but an error occurred while fetching your pull request"
    end
  end

  def register(m, login = nil, code = nil)
    if login and code
      token = api.get_token(code)
      user = User.new(token: token.token, nick: m.user.nick, login: login)
      user.save!
      m.user.msg "successfuly registered token: #{user.token}"
    else
      m.user.msg api.authorize_url :scope => 'repo'
    end
  rescue OAuth2::Error
    m.user.msg "provided code is invalid"
  end

  def api(message = nil)
    config = send(:config)

    if message and user = User.with(:nick, message.user.nick)
      config.merge!(oauth_token: user.token)
    end

    Github.new(config)
  end

  private

  class User < Ohm::Model
    attribute :nick
    attribute :login
    attribute :token

    unique :nick
    unique :login
    unique :token

    def validate
      assert_present :nick
      assert_present :login
      assert_present :token
    end
  end

  def config
    self.class.config.symbolize_keys
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
