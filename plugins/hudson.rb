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
    if October::Plugins.registered["Hudson"]
      tr = TestRun.new(project_name, build)
      issues = @bot.plugins.detect{|a| a.is_a? Issues}
      pull = issues.pull_request(m, tr.branch)
      issues.comment(m, pull["number"], "Green: #{url}") if pull
    end
  end

  def update_branch(m, new_branch, job_name)
    job_name = m.user.to_s if job_name.blank?
    config = Config.new(job_name)
    config.update_branch(new_branch)
    m.reply "Job updated"
  rescue
    m.reply "Error updating job"
  end

  def build(m, job_name)
    job_name = m.user.to_s if job_name.blank?
    config = Config.new(job_name)
    config.build
    m.reply "Build scheduled"
  rescue
    m.reply "Failed to schedule the build"
  end
end
