require 'october/plugin'
require 'octokit'

module October
  module Plugin
    class Github
      include October::Plugin
      include Celluloid::Notifications

      attr_reader :client

      def initialize(*)
        super # TODO: do not require plugin to have initialize, use attr accessors instead

        if (channel = shared['github'])
          subscribe(/^#{channel}/, :new_webhook)
        end

        @client = Octokit.client
      end

      match /\s(\w+): (\{.+\})$/, prefix: 'github event'

      def execute(m, event, payload)
        handler = "handle_#{event}"

        if respond_to?(handler)
          public_send(handler, payload)
        else
          @bot.logger.debug  "[plugin] #{self.class.plugin_name}: no handler for #{event}"
        end
      end

      def handle_issues(*args)
        # slack message
      end

      def handle_deployment_status(payload)
        info = JSON.parse(payload)
        channel.send "Hah, deployed!"
      end

      def new_webhook(topic, event)
        # celluloid notification
        _prefix, *rest = topic.split('.')

        chain = []
        rest.each do |part|
          chain << part
          m = chain.join('_')
          __send__(m, event) if respond_to?(m)
        end
      end

      def issues_assigned(event)
        member = teams.find do |team|
          team.has_member?(event.assignee)
        end

        if member
          issue = Issue.new(client.get(event.url))
          assign_team(issue, member)
        end
      end

      protected

      def assign_team(issue, team)
        client.add_labels_to_an_issue(issue.repository, issue.number, Array(team.label))
      end

      def teams
        client.org('3scale/teams').map(&Team).select(&:has_label?)
      end

      class Issue
        def initialize(octokit)
          @octokit = octokit
        end

        def repository
          name = @octokit.rels[:repository].get.data[:full_name]
          Octokit::Repository.new(name)
        end

        def number
          @octokit[:number]
        end
      end

      class Team
        def self.to_proc; ->(octokit) { new(octokit) }; end

        def initialize(octokit)
          @octokit = octokit
        end

        def has_label?
          description.start_with?(label)
        end

        def description
          @octokit[:description] || ''
        end

        def label
          "T-#{@octokit[:name]}"
        end

        def has_member?(login)
          @octokit.rels[:members].head(uri: { member: login }).status == 204
        rescue Octokit::NotFound
          false
        end
      end

      def channel
        name = config['channel'] || shared['github']
        Channel(name)
      end
    end
  end
end