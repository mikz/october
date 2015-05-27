class Hudson
  include October::Plugin

  autoload :Fetcher, 'hudson/fetcher'
  autoload :Reporter, 'hudson/reporter'
  autoload :TestRun, 'hudson/test_run'
  autoload :Config, 'hudson/config'
  autoload :Project, 'hudson/project'

  FAILED = /(?:failures|failed|f)/
  NUMBER = /(?:\/(\d+))?/
  JOB = /([\w\-\.]+?)/
  BUILD = /#{JOB}#{NUMBER}/

  match /#{FAILED}(?:\s+#{BUILD})?$/, method: :failures
  match /(?:failures|failed|f) #{BUILD} diff #{BUILD}$/, method: :diff

  match /Project (.+?) build #(\d+):.+(?:SUCCESS|FIXED).+(?:.+?): (.*)$/, method: :green, :use_prefix => false
  match /Project (.+?) build #(\d+):.+(?:STILL FAILING|FAILURE).+(?:.+?): (.*)$/, method: :red, :use_prefix => false
  match /Project (.+?) build #(\d+):.+(?:ABORTED).+(?:.+?): (.*)$/, method: :grey, :use_prefix => false

  match /(?:job|j) (\S*)(?: ?)(.*?)$/, method: :update_branch
  match /(?:build|b)(?: ?)(.*?)$/, method: :build

  match /jb\s+(\S+)(?:\s+(\S+)?)?$/, method: :update_and_build

  register_help 'failures|failed|f project', 'list failed tests (cukes and test units) from last test run'
  register_help 'failures|failed|f project/test_number', 'list failed tests from specific test run'
  register_help 'failures|failed|f project/test_number diff another/test', 'list only difference between these two tests'
  register_help 'build [job_name]', 'builds your personal project or the given job'
  register_help 'job branch_name [job_name]', 'updates your personal project or the specified job to build the given branch'

  def failures(m, job = nil, test_run = nil)
    job ||= m.user
    test = TestRun.new(job, test_run)
    reporter = Reporter.new(test)

    m.user.msg reporter.report
  rescue Fetcher::HTTPError
    m.user.msg $!.message
  end

  def diff(m, *projects)
    tests = projects.in_groups_of(2).map {|project, number|
      TestRun.new project, number
    }
    reporter = Reporter.new *tests
    m.user.msg reporter.diff
  rescue Fetcher::HTTPError
    m.user.msg $!.message
  end

  def green(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job, repo|
      issues.api.repos.statuses.create(repo[:owner], repo[:name], job.sha, state: 'success', target_url: url)
      m.reply "#{pull['html_url']} marked as green"
    end
  end

  def red(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job, repo|

      issues.api.repos.statuses.create(repo[:owner], repo[:name], job.sha, state: 'failure', target_url: url)
      m.reply "#{pull['html_url']} marked as red"
    end
  end

  def grey(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job, repo|
      issues.api.repos.statuses.create(repo[:owner], repo[:name], job.sha, state: 'error', target_url: url)
      m.reply "#{pull['html_url']} marked as grey"
    end
  end

  def update_branch(m, new_branch, job_name)
    job_name = m.user.to_s if job_name.blank?
    config = Config.new(job_name)
    config.update_branch(new_branch)
    m.reply "Job '#{job_name}' set to build branch '#{new_branch}'"
  rescue
    m.reply "Error updating job"
  end

  def build(m, job_name)
    job_name = m.user.to_s if job_name.blank?

    config = Config.new(job_name)
    config.build
    m.reply "Build of '#{job_name}' scheduled"
  rescue
    m.reply "Failed to schedule a build for '#{job_name}'"
  end

  def update_and_build(m, new_branch, job_name)
    job_name = m.user.to_s if job_name.blank?

    config = Config.new(job_name)
    config.update_branch(new_branch)
    config.build

    m.user.msg "#{job_name} set up to build #{new_branch} and fired one"
  rescue
    m.reply "Failed to update job #{job_name} and fire build of #{new_branch}"
  end

  private
  def issues
    @issues ||= @bot.plugins.detect{|a| a.is_a? Issues}
  end

  def api
    config = Issues.config.symbolize_keys
    Github.new(config)
  end

  def pull_requests(user = api.user, repo = api.repo)
    Issues::Retryable.do { api.pull_requests.list(user, repo) }
  end

  def pull_request(project_name, build)
    tr = TestRun.new(project_name, build)

    project = tr.project
    pr = pull_requests(project.org, project.repo).find { |pr| pr["head"]["ref"] == tr.branch }

    repo = { name: pr['head']['repo']['name'], owner: pr['head']['repo']['owner']['login'] }

    if pr
      yield pr, tr, repo
    end
  end
end
