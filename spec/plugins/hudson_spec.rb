require 'spec_helper'
require 'hudson'

describe Hudson do
  include_context :bot
  let(:plugin) { Hudson.new(bot) }

  # init plugin
  before(:each) { plugin }

  describe "#handlers" do
    let(:handlers) { plugin.handlers }
    subject { plugin.handlers }

    let(:raw) { "PRIVMSG #channel :#{msg}" }
    let(:message) { Cinch::Message.new( raw , bot ) }

    # FIXME: this is really silly solution
    let(:failures) { handlers.first }
    let(:diff) { handlers.second }

    describe "valid message" do
      subject { bot.handlers.find(:message, message) }
      let(:msg) { self.class.description }

      describe "!f job/21 diff another/31" do
        it { should == [diff] }
      end

      describe "!f my-job" do
        it { should == [failures] }
      end

      describe "!f job/21" do
        it { should == [failures] }
      end

      describe "!f my-job-1.9.3" do
        it { should == [failures] }
      end
    end

  end
end
