RSpec.describe October::Plugin do
  subject(:mod) { described_class }

  let(:klass) { Class.new }

  it { is_expected.to be_a(Module) }

  context 'plugin with october module' do
    subject(:plugin) do
      Class.new.include(mod)
    end

    it { expect(plugin.ancestors).to include(Cinch::Plugin) }
    it { expect(plugin.ancestors).to include(October::Plugin) }

    it 'registers help' do
      plugin.register_help('command', 'some help')
      expect(mod.help).to include('command' => 'some help')
    end
  end

end
