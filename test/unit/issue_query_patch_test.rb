require File.expand_path '../../test_helper', __FILE__

class IssueQueryPatchTest < ActiveSupport::TestCase
  test 'IssueQuery is patched' do
    patch = RedmineNewIssueView::Patches::IssueQueryPatch
    assert_includes IssueQuery.included_modules, patch
    %i(statement_without_target_version_status
      statement_with_target_version_status
      available_filters_without_target_version_status
      available_filters_with_target_version_status).each do |method|
        assert_includes IssueQuery.instance_methods, method
      end
  end
end
