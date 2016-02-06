require 'october/plugin'
require 'roda'
require 'json'

module October
  module Plugin
    class GithubWebhooks
      include October::Plugin

      class Event < Struct.new(:payload, :name)

        # http://rubular.com/r/FuDNTjpWW8
        EVENT_NAME = /(?<event>[^:]+?)(?:Event)?$/.freeze

        NORMALIZE_NAME = ->(match) do
          # http://rubular.com/r/zA5ucftSdw
          match[:event].gsub(/(\w)?([A-Z])/) { $~.captures.compact.join('_').downcase }
        end

        class << self
          @@events = []

          def events
            @@events
          end

          def parse!(request)
            name = request.env.fetch('HTTP_X_GITHUB_EVENT')
            payload = JSON.parse(request.body.read)

            entity = events.find { |e| e.event == name } || self

            entity.new(payload, name)
          end

          def inherited(subclass)
            events << subclass
            subclass.event = subclass.name.match(EVENT_NAME, &NORMALIZE_NAME)
          end

          attr_accessor :event
        end

        def initialize(*)
          super
        end

        def as_json(*)
          { }
        end

        def name
          super || self.class.event
        end

        def to_json(options = {})
          as_json.to_json(options)
        end

        def to_s
          "github event #{name}: #{to_json}"
        end
      end

      class DeploymentEvent < Event
        def initialize(*)
          super
          @deployment = payload.fetch('deployment')
          @sha = @deployment.fetch('sha')
          @environment = @deployment.fetch('environment')
          @creator = @deployment.fetch('creator').fetch('login')
        end

        def as_json(*)
          { environment: @environment, creator: @creator, sha: @sha }
        end
      end

      class StatusEvent < Event
        def initialize(*)
          super
          @context = payload.fetch('context')
          @state = payload.fetch('state')
        end

        def as_json(*)
          { context: @context, state: @state }
        end
      end


      class PushEvent < Event
        def initialize(*)
          super
          @ref = payload.fetch('ref')
          @before = payload.fetch('before')
          @after = payload.fetch('after')
        end

        def as_json(*)
          { ref: @ref, before: @before, after: @after }
        end
      end

      module EventAction
        def initialize(*)
          super
          @action = payload.fetch('action')
        end

        def as_json(*)
          super.merge(action: @action)
        end
      end

      class IssuesEvent < Event
        attr_reader :label, :assignee
        include EventAction
        def initialize(*)
          super
          @assignee = payload['assignee']
          @label = payload['label']
        end

        def as_json(*)
          super.merge(label: label, assignee: assignee)
        end
      end

      class PullRequestEvent < Event
        include EventAction
        attr_reader :number

        def initialize(*)
          super
          @number = payload.fetch('number')
        end

        def as_json(*)
          super.merge(number: number)
        end
      end

      class DeploymentStatusEvent < DeploymentEvent

        def initialize(*)
          super
          @deployment_status = payload.fetch('deployment_status')
          @state = @deployment_status.fetch('state')
        end

        def as_json(*)
          super.merge(state: @state, environment: @environment)
        end
      end

      class Server < ::Roda
        route do |r|

          r.post do
            bot = env['october.bot']
            plugin = env['october.plugin']

            event = Event.parse!(request)

            plugin.announce(event)

            response['Content-Type'] = request.content_type
            event.to_json
          end
        end

      end

      app Server.app

      self.plugin_name = 'github-webhooks'

      def announce(event)
        channel = shared['github'] or fail 'missing channel configuration'

        october = client.channels[channel] or fail "unknown channel: #{channel}"

        client.message(event, to: october)
      end
    end
  end
end
