RSpec.describe October::Server do

  subject(:server) { described_class }

  it do
    expect(Rack::Server).to receive(:new).with(hash_including(app: server.app))
    server.server
  end
end
