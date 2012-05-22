require 'typhoeus'

class Hudson
  include October::Plugin

  autoload :Fetcher, 'hudson/fetcher'
  autoload :Reporter, 'hudson/reporter'
  autoload :TestRun, 'hudson/test_run'
  autoload :Config, 'hudson/config'

  HYDRA = Typhoeus::Hydra.new

  FAILED = /(?:failures|failed|f)/
  BUILD = /(?:\/(\d+))?/
  JOB = /([\w\-\.]+?)/

  match /#{FAILED} #{JOB}#{BUILD}$/, method: :failures
  match /(?:failures|failed|f) #{JOB}#{BUILD} diff #{JOB}#{BUILD}$/, method: :diff
  match /Project (.+?) build #(\d+): (?:SUCCESS|FIXED) (?:.+?): (.*)$/, method: :green, :use_prefix => false
  match /(?:job) #{JOB} (.*)$/, method: :update_branch

  register_help 'failures|failed|f project', 'list failed tests (cukes and test units) from last test run'
  register_help 'failures|failed|f project/test_number', 'list failed tests from specific test run'
  register_help 'failures|failed|f project/test_number diff another/test', 'list only difference between these two tests'

  def failures(m, project, test_run = nil)
    test = TestRun.new project, test_run
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

  def update_branch(m, project_name, new_branch)
    config = Config.new(project_name)
    config.update_branch(new_branch)
    m.reply "Job updated"
  rescue
    m.reply "Error updating job"
  end
end
