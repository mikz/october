RSpec.describe October::Plugin::Help do
  include_context :plugin

  def message(msg)
    Cinch::Message.new(":nick!nick@example.com MSG #{msg}", bot)
  end

  it do
    resp = plugin.help message('hello')
    expect(resp).to include('October help:')
    expect(resp).to include('  !help - list all registered commands with description')
  end

end
