# frozen_string_literal: true

RSpec.describe October::Plugin::Help do
  include_context :plugin

  def message(text)
    Slack::Messages::Message.new('ok' => true, 'channel' => { 'id' => 'somechannel' }, 'text' => text)
  end

  it do
    resp = plugin.help message('hello')
    text = resp.fetch('text')
    expect(text).to include('October help:')
    expect(text).to include('  !help - list all registered commands with description')
  end

  before do
    stub_request(:post, 'https://slack.com/api/rtm.start')
      .to_return(status: 200, body: { ok: true }.to_json, headers: {})

    bot.client.slack.start_async
  end
end
