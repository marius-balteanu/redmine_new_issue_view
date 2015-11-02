require 'spec_helper'

describe IssuesHelper, type: :helper do
  it 'is patched with RedmineNewIssueView::Patches::IssuesHelperPatch' do
    patch = RedmineNewIssueView::Patches::IssuesHelperPatch
    expect(IssuesHelper.included_modules).to include(patch)
  end
end
