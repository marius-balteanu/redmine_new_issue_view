require File.expand_path '../../test_helper', __FILE__

class QueriesHelperPatchTest < ActiveSupport::TestCase
  test 'QueriesHelper is patched' do
    patch = RedmineNewIssueView::Patches::QueriesHelperPatch
    assert_includes QueriesHelper.included_modules, patch
    %i(column_value_without_issue_id
      column_value_with_issue_id).each do |method|
        assert_includes QueriesHelper.instance_methods, method
      end
  end
end
