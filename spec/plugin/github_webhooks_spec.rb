require 'october/plugin/github_webhooks'

RSpec.describe October::Plugin::GithubWebhooks do
  include_context :plugin

  it { is_expected.to be }

  it 'has application' do
    expect(described_class.mounts).to have_key(described_class.method(:plugin_name))
    expect(described_class)
  end
end


RSpec.describe October::Plugin::GithubWebhooks::Server do
  include_context :rack
  include_context :plugin

  let(:plugin_class) { October::Plugin::GithubWebhooks }

  let(:env) do
    { 'october.bot' => bot, 'october.plugin' => plugin }
  end

  before do
    # plugin.shared.merge!('github' => '#channel')
  end

  context 'deployment webhook' do
    let(:webhook) { open('spec/fixtures/webhooks/deployment.json').read }

    it 'works' do
      expect(plugin).to receive(:announce).with(an_instance_of(October::Plugin::GithubWebhooks::DeploymentEvent))
      post '/', headers: { 'X-GitHub-Event' => 'deployment' }, params: webhook, env: env
      expect(last_response.body).to eq('{"environment":"october-3scale","creator":"mikz","sha":"c844384ce5d0a2e29cc2a1727182b0dddff074d6"}')
    end
  end

  context 'deployment_status webhook' do
    let(:webhook) { open('spec/fixtures/webhooks/deployment_status.json').read }

    it 'works' do
      expect(plugin).to receive(:announce).with(an_instance_of(October::Plugin::GithubWebhooks::DeploymentStatusEvent))
      post '/', headers: { 'X-GitHub-Event' => 'deployment_status' }, params: webhook, env: env
      expect(last_response.body).to eq('{"environment":"october-3scale","creator":"mikz","sha":"445083e568e2771cdec5e30051ce6cd918ce28bb","state":"success"}')
    end
  end


  context 'pull_request webhook' do
    let(:webhook) { open('spec/fixtures/webhooks/pull_request.json').read }

    it 'works' do
      expect(plugin).to receive(:announce).with(an_instance_of(October::Plugin::GithubWebhooks::PullRequestEvent))
      post '/', headers: { 'X-GitHub-Event' => 'pull_request' }, params: webhook, env: env
      expect(last_response.body).to eq('{"action":"synchronize","number":29}')
    end
  end


  context 'push webhook' do
    let(:webhook) { open('spec/fixtures/webhooks/push.json').read }

    it 'works' do
      expect(plugin).to receive(:announce).with(an_instance_of(October::Plugin::GithubWebhooks::PushEvent))
      post '/', headers: { 'X-GitHub-Event' => 'push' }, params: webhook, env: env
      expect(last_response.body).to eq('{"ref":"refs/heads/v2","before":"445083e568e2771cdec5e30051ce6cd918ce28bb","after":"c844384ce5d0a2e29cc2a1727182b0dddff074d6"}')
    end
  end

  context 'status webhook' do
    let(:webhook) { open('spec/fixtures/webhooks/status.json').read }

    it 'works' do
      expect(plugin).to receive(:announce).with(an_instance_of(October::Plugin::GithubWebhooks::StatusEvent))
      post '/', headers: { 'X-GitHub-Event' => 'status' }, params: webhook, env: env
      expect(last_response.body).to eq('{"context":"continuous-integration/travis-ci/push","state":"pending"}')
    end
  end

end
