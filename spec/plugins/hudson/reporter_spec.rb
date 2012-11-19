require 'spec_helper'
require 'hudson/reporter'

describe Hudson::Reporter do

  describe "#report" do
    let(:test) { mock(:test, project: 'name', number: 42, failures: ['first','second']) }
    subject(:report) { Hudson::Reporter.new(test).report }

    its(:header) { should include 'name/42' }
    its(:length) { should == 2 }
    its(:to_s) { should include report.header, 'first', 'second' }
  end

  describe "#diff" do
    let(:first) { mock(:first, project: 'first', number: 1, failures: ['first','second']) }
    let(:fifth) { mock(:fifth, project: 'fifth', number: 5, failures: ['second','third']) }

    subject(:diff) { Hudson::Reporter.new([first, fifth]).diff }

    its(:header) { should include "first/1 <=> fifth/5" }
    its(:length) { should == 3 }
    its(:to_s) { should include diff.header, '- first', 'second', '+ third' }
  end

  describe "#respond" do
    let(:reporter) { Hudson::Reporter.new(test) }
    let(:stub_test) { stub_request(:get, 'http://localhost:8080/job/test/42/consoleText') }

    before do
      stub_test
    end
  end
end
