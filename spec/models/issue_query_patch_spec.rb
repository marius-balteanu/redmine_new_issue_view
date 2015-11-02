require 'spec_helper'

describe IssueQuery, type: :model do
  it 'is patched with RedmineNewIssueView::Patches::IssueQueryPatch' do
    patch = RedmineNewIssueView::Patches::IssueQueryPatch
    expect(IssueQuery.included_modules).to include(patch)
  end
end
