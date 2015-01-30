require 'spec_helper'
require 'hudson/reporter'

describe Hudson::Reporter do
  let(:test) { double(:test, project: 'name', number: 42, failures: ['first','second']) }

  describe "#report" do
    subject(:report) { Hudson::Reporter.new(test).report }

    its(:header) { should include 'name/42' }
    its(:length) { should == 2 }
    its(:to_s) { should include report.header, 'first', 'second' }
  end

  describe "#diff" do
    let(:fifth) { double(:fifth, project: 'fifth', number: 5, failures: ['second','third']) }

    subject(:diff) { Hudson::Reporter.new([test, fifth]).diff }

    its(:header) { should include "name/42 <=> fifth/5" }
    its(:length) { should == 3 }
    its(:to_s) { should include diff.header, '- first', 'second', '+ third' }
  end
end
