require 'spec_helper'

describe QueriesHelper, type: :helper do
  it 'is patched with RedmineNewIssueView::Patches::QueriesHelperPatch' do
    patch = RedmineNewIssueView::Patches::QueriesHelperPatch
    expect(QueriesHelper.included_modules).to include(patch)
  end
end
