gem 'typhoeus'

class Hudson
  include October::Plugin

  autoload :Fetcher, 'hudson/fetcher'
  autoload :Reporter, 'hudson/reporter'
  autoload :TestRun, 'hudson/test_run'

  HYDRA = Typhoeus::Hydra.new

  match /hudson (?:failures|failed|f) (.+?)\/(\d+)/, method: :failures
  match /hudson (?:failures|failed|f) (.+?)\/(\d+) diff (.+?)\/(\d+)/, method: :diff

  def failures(m, project, test_run)
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

end
