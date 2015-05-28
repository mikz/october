RSpec.shared_context :bot do
  module TestingIRC
    attr_accessor :queue
  end

  class FakeSocket

  end

  let(:irc) { Cinch::IRC.new(bot).extend(TestingIRC) }
  let(:queue) { Cinch::MessageQueue.new(socket, bot) }
  let(:socket) { FakeSocket.new }

  let(:bot) { October::Bot.new }

  let(:log) { StringIO.new }
  let(:logger) { Cinch::Logger.new(log) }

  before do
    irc.queue = queue

    bot.loggers.replace([logger])
    bot.set_nick 'bot'
    bot.sync(:user, 'bot', true)
    bot.sync(:host, 'localhost', true)

    allow(bot).to receive(:irc) { irc.setup; irc }
  end
end