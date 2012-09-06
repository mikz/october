require 'typhoeus'

class Hudson
  include October::Plugin

  autoload :Fetcher, 'hudson/fetcher'
  autoload :Reporter, 'hudson/reporter'
  autoload :TestRun, 'hudson/test_run'
  autoload :Config, 'hudson/config'

  HYDRA = Typhoeus::Hydra.new

  FAILED = /(?:failures|failed|f)/
  NUMBER = /(?:\/(\d+))?/
  JOB = /([\w\-\.]+?)/
  BUILD = /#{JOB}#{NUMBER}/

  match /#{FAILED}(?:\s+#{BUILD})?$/, method: :failures
  match /(?:failures|failed|f) #{BUILD} diff #{BUILD}$/, method: :diff

  match /Project (.+?) build #(\d+): (?:SUCCESS|FIXED) (?:.+?): (.*)$/, method: :green, :use_prefix => false
  match /Project (.+?) build #(\d+): (?:STILL FAILING|FAILURE) (?:.+?): (.*)$/, method: :red, :use_prefix => false
  match /Project (.+?) build #(\d+): (?:ABORTED) (?:.+?): (.*)$/, method: :grey, :use_prefix => false

  match /(?:job|j) (\S*)(?: ?)(.*?)$/, method: :update_branch
  match /(?:build|b)(?: ?)(.*?)$/, method: :build

  register_help 'failures|failed|f project', 'list failed tests (cukes and test units) from last test run'
  register_help 'failures|failed|f project/test_number', 'list failed tests from specific test run'
  register_help 'failures|failed|f project/test_number diff another/test', 'list only difference between these two tests'
  register_help 'build [job_name]', 'builds your personal project or the given job'
  register_help 'job branch_name [job_name]', 'updates your personal project or the specified job to build the given branch'

  def failures(m, job = nil, test_run = nil)
    job ||= m.user
    test = TestRun.new job, test_run
    reporter = Reporter.new test

    reporter.respond :report, m
  end

  def diff(m, *projects)
    tests = projects.in_groups_of(2).map {|project, number|
      TestRun.new project, number
    }
    reporter = Reporter.new *tests

    reporter.respond :diff, m
  end

  def green(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job|
      # issues.comment(m, pull["number"], "Green: #{url}")
      issues.api.repos.statuses.create(nil, nil, job.sha, state: 'success', target_url: url)
    end
  end

  def red(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job|
      issues.api.repos.statuses.create(nil, nil, job.sha, state: 'failure', target_url: url)
    end
  end

  def grey(m, project_name, build, url)
    pull_request(project_name, build) do |pull, job|
      issues.api.repos.statuses.create(nil, nil, job.sha, state: 'error', target_url: url)
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

  private
  def issues
    @bot.plugins.detect{|a| a.is_a? Issues}
  end

  def pull_request(project_name, build)
    if October::Plugins.registered["Hudson"]
      tr = TestRun.new(project_name, build)

      if pull = issues.pull_request(tr.branch)
        yield pull, tr
      end
    end
  end
end
