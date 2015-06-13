RSpec.shared_context :plugin do
  include_context :bot
  subject(:plugin) { described_class.new(bot) }
end
