shared_context :bot do
  let(:irc) { Cinch::IRC.new(bot) }
  let(:bot) { October::Base.new }
  before(:each) { bot.stub(:irc) { irc } }
end
