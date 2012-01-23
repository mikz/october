require 'spec_helper'
require 'hudson'

describe Hudson do
  include_context :bot

  describe "#handlers" do
    subject { Hudson.new(bot) }
  end
end
