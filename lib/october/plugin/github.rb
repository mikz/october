# frozen_string_literal: true

require 'october/plugin'
require 'octokit'

module October
  module Plugin
    class Github
      include October::Plugin
      include Celluloid::Notifications

      attr_reader :client

      finalizer :finalize

      def initialize(*)
        super # TODO: do not require plugin to have initialize, use attr accessors instead

        if (pattern = channel_pattern)
          @subscriber = subscribe(pattern, :new_webhook)
        end

        @client = Octokit.client
      end

      match /\s(\w+): (\{.+\})$/, prefix: 'github event'

      def execute(_m, event, payload)
        handler = "handle_#{event}"

        if respond_to?(handler)
          public_send(handler, payload)
        else
          @bot.logger.debug "[plugin] #{self.class.plugin_name}: no handler for #{event}"
        end
      end

      def handle_issues(*args)
        # slack message
      end

      def handle_deployment_status(payload)
        info = JSON.parse(payload)
        channel.send 'Hah, deployed!'
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

      def assigned(event)
        member = teams.find do |team|
          team.has_member?(event.assignee)
        end

        if member
          issue = Issue.new(client.get(event.url))
          assign_team(issue, member)
        end
      end

      alias issues_assigned assigned
      alias pull_request_assigned assigned

      def pull_request_opened(event)
        unless event.assignee
          issue = Issue.new(client.get(event.url))

          assign_user(issue, event.user) unless issue.assignee
        end
      end

      protected

      def finalize
        unsubscribe(@subscriber) if @subscriber
      end

      def assign_team(issue, team)
        client.add_labels_to_an_issue(issue.repository, issue.number, Array(team.label))
      end

      def assign_user(issue, user)
        client.patch(issue.href, assignee: user)
      end

      def teams
        client.org('3scale/teams').map(&Team).select(&:has_label?)
      end

      class Issue
        def initialize(octokit)
          @octokit = octokit
        end

        def issue
          @_issue ||= begin
            if (issue = @octokit.rels[:issue])
              self.class.new(issue.get.data)
            else
              self
            end
          end
        end

        def href
          if issue == self
            @octokit[:url]
          else
            issue.href
          end
        end

        def assignee
          @octokit[:assignee]
        end

        def repository
          repo = @octokit.rels[:repository]

          if repo
            Octokit::Repository.new(repo.get.data[:full_name])
          else
            issue.repository
          end
        end

        def number
          @octokit[:number]
        end
      end

      class Team
        def self.to_proc
          ->(octokit) { new(octokit) }
        end

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

      def channel_pattern
        channel = (shared['channel'] || shared['github'])

        /^#{channel}/ if channel
      end
    end
  end
end
