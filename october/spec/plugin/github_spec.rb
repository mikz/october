require 'october/plugin/github'

RSpec.describe October::Plugin::Github do
  include_context :plugin

  it { is_expected.to be }

  it 'has application' do
    expect(described_class.mounts).to eq('october' => described_class::Server)
    expect(described_class)
  end
end
