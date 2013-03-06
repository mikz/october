require 'spec_helper'
require 'hudson/test_run'

describe Hudson::TestRun do
  let(:test_run) { Hudson::TestRun.new('name', 42) }
  let(:log) { File.read('spec/fixtures/hudson/console.log') }

  before(:each) { test_run.stub(:log) { log } }

  subject { test_run }

  its(:cucumbers) { should == %w|features/signup/fields.feature:25 features/accounts/bulk_operations/change_plans.feature:34| }
  its(:test_unit) { should == [
    "test/unit/logic/signup_test.rb -n 'test: Provider #signup_with_plans yields block with buyer and user should set validate_fields for buyer and user. '",
    "(missing file) -n 'test: Connector should require account to be set. '",
    "(missing file) -n 'test_create_dupe_end_user'"
  ] }
end
