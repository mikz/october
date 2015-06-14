RSpec.shared_context :plugin do
  include_context :bot
  let(:plugin_class) { described_class }
  subject(:plugin) { plugin_class.new(bot) }
end
