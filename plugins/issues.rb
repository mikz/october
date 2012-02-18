require 'github_api'

class Issues
  include October::Plugin

  prefix /^!issues? /
  register_help 'issue create title', 'ceate issue'
  register_help 'issue convert number head => base', 'convert issue to pull request'

  match /create (.+)$/, method: :create
  match /convert (\d+) (.+?)\s*=>\s*(.+)$/, method: :convert

  def create(m, text)
    issue = api.issues.create_issue nil, nil, :title => text
    m.reply "created issue #{issue.number} - #{issue.html_url}"
  end

  def convert(m, number, head, base)
    pull = api.pull_requests.create_request nil, nil, :issue => number, :head => head, :base => base
    m.reply "converted issue #{number} to pull request"
  end

  private

  def config
    self.class.config.symbolize_keys
  end

  def api
    @api ||= Github.new config
  end

end
