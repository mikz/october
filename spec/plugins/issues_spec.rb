require 'spec_helper'
require 'issues'

describe Issues do
  describe 'issue parser' do
    subject { Issues::IssueParser.new text }

    context 'with all options' do
      let(:text) { "This is issue | and this is body | milestone: ms | assign: person" }

      its(:assignee) { should == 'person' }
      its(:milestone) { should == 'ms' }
      its(:title) { should == 'This is issue' }
      its(:body) { should == 'and this is body' }

      its(:to_hash) { should == { title: 'This is issue', assignee: 'person', milestone: 'ms', body: 'and this is body'} }
    end

    context 'just simple' do
      let(:text) { "title | body" }

      its(:title) { should == "title" }
      its(:body) { should == "body" }
    end
  end
end
