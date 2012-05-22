require 'open-uri'

class Hudson
  class Config
    BASE_URL = "http://localhost:8080"
    CONFIG_URL = "/job/<project>/config.xml"

    attr_reader :job

    def initialize(job)
      @job = job
    end

    def config_url
      (BASE_URL + CONFIG_URL).gsub('<project>', job)
    end

    def config
      @config ||= Nokogiri::XML(open(config_url))
    end

    def update_branch(branch_name)
      config.xpath('/project/scm/branches/hudson.plugins.git.BranchSpec/name').each do |branch|
        branch.content = branch_name
      end

      Curl::Easy.http_post(config_url, config.to_s) do |curl|
        curl.headers['Content-Type'] = 'text/xml'
      end
    end
  end
end
