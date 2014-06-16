require 'spec_helper'
require 'hudson/fetcher'

Hudson::Fetcher.base_url = 'https://localhost:8080'

describe Hudson::Fetcher do

  let(:test_run) { mock(:test_run, :job => 'whatever', :number => 13) }
  let(:fetcher) { Hudson::Fetcher.new(test_run) }
  let(:stub_console_text) { stub_request(:get, 'https://localhost:8080/job/whatever/13/consoleText').
                              to_return(status: 200, body: build_log) }
  let(:build_log) { File.read('spec/fixtures/hudson/console.log') }

  describe '#response' do

    before { stub_console_text }

    subject(:response) { fetcher.response }
    its(:body) { should == build_log }
  end
end
