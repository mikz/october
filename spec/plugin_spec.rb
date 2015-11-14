RSpec.describe October::Plugin do
  subject(:mod) { described_class }

  let(:klass) { Class.new }

  it { is_expected.to be_a(Module) }

  context 'plugin with october module' do
    include_context :bot

    subject(:plugin) do
      Class.new.include(mod)
    end

    it { expect(plugin.ancestors).to include(October::Plugin) }

    it 'registers help with description' do
      plugin.register_help('command', 'some help')
      expect(mod.help).to include('command' => 'some help')
    end

    it 'registers help without description' do
      plugin.register_help('command')
      expect(mod.help).to include('command' => nil)
    end

    it 'mounts app' do
      plugin.mount('prefix', app = Proc.new{})
      expect(plugin.mounts).to eq('prefix' => app)
    end

    it 'registers mounted app' do
      plugin.mount('prefix', app = Proc.new{})

      expect(October::Server).to receive(:run).with('prefix', app)
      plugin.new(bot)
    end
  end

end
