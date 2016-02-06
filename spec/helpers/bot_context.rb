module BotContext
  module TestingIRC
    attr_accessor :queue
  end

  class FakeSocket

  end
end

RSpec.shared_context :bot do
  let(:socket) { BotContext::FakeSocket.new }

  let(:bot) { October::Bot.new(concurrency: :fake) }

  let(:log) { StringIO.new }

  before do

  end
end
