require 'spec_helper'
require 'october/environment'

class TestClass
  extend October::Environment
end

describe TestClass do
 before(:each) { FakeFS.activate! }
 after(:each)  { FakeFS.deactivate! }

 let(:file) { 'irc.yml' }
 let(:config) { Dir.mkdir('config'); File.join('config', file) }
 let(:content) do
%{test:
  key: val
}
 end

 it "should load exising file" do
   File.open(config, 'w') {|f| f << content }
   TestClass.configuration(file, :test).should == {'key' => 'val'}
 end

 it "should return nil when file does not exist" do
   TestClass.configuration('bogus', :custom).should == nil
 end
end
