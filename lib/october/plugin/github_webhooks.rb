require 'october/plugin'
require 'roda'
require 'json'
require 'celluloid/current'
require 'openssl'
require 'rack/utils'

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

          class SignatureMismatchError < StandardError; end

          def verify_signature!(request, payload_body)
            signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV.fetch('GITHUB_SECURE_TOKEN'){ return }, payload_body)
            raise SignatureMismatchError, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env.fetch('HTTP_X_HUB_SIGNATURE'))
          end

          def parse!(request)
            name = request.env.fetch('HTTP_X_GITHUB_EVENT')
            body = request.body.read
            verify_signature!(request, body)
            payload = JSON.parse(body)

            Celluloid.logger.debug JSON.pretty_generate(payload)

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

        def scope
          [name]
        end

        def to_json(options = {})
          as_json.to_json(options)
        end

        def to_s
          "github event #{name}: #{to_json}"
        end
      end

      class DeploymentEvent < Event
        attr_reader :deployment, :sha, :environment, :creator

        def initialize(*)
          super
          @deployment = payload.fetch('deployment')
          @sha = @deployment.fetch('sha')
          @environment = @deployment.fetch('environment')
          @creator = @deployment.fetch('creator').fetch('login')
        end

        def scope
          super + [ environment ]
        end

        def as_json(*)
          { environment: environment, creator: creator, sha: sha }
        end
      end

      class StatusEvent < Event
        attr_reader :context, :state

        def initialize(*)
          super
          @context = payload.fetch('context')
          @state = payload.fetch('state')
        end

        def scope
          super + [ context ]
        end

        def as_json(*)
          { context: context, state: state }
        end
      end


      class PushEvent < Event
        attr_reader :ref, :before, :after

        def initialize(*)
          super
          @ref = payload.fetch('ref')
          @before = payload.fetch('before')
          @after = payload.fetch('after')
        end

        def scope
          super + [ ref ]
        end

        def as_json(*)
          { ref: ref, before: before, after: after }
        end
      end

      module EventAction
        attr_reader :action

        def initialize(*)
          super
          @action = payload.fetch('action')
        end

        def scope
          super + [ action ]
        end

        def as_json(*)
          super.merge(action: @action)
        end
      end

      class IssueCommentEvent < Event
        attr_reader :user
        include EventAction

        def initialize(*)
          super
          @user = payload.fetch('comment').fetch('user').fetch('login')
        end

        def as_json(*)
          super.merge(user: user)
        end
      end

      class IssuesEvent < Event
        attr_reader :label, :assignee, :url
        include EventAction

        def initialize(*)
          super
          @url = payload.fetch('issue').fetch('url')
          @assignee = payload.dig('assignee', 'login')
          @label = payload.dig('label','name')
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
        attr_reader :state

        def initialize(*)
          super
          @deployment_status = payload.fetch('deployment_status')
          @state = @deployment_status.fetch('state')
        end

        def scope
          super + [ state ]
        end

        def as_json(*)
          super.merge(state: state, environment: environment)
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
        pub_chan = ([channel] + event.scope).join('.')
        Celluloid.publish(pub_chan, event)

        october = client.channels[channel] or fail "unknown channel: #{channel}"

        client.message(event, to: october)
      end
    end
  end
end
