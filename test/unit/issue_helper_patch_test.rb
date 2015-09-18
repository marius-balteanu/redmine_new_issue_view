require File.expand_path '../../test_helper', __FILE__

class IssueHelperPatchTest < ActiveSupport::TestCase
  test 'IssuesHelper is patched' do
    patch = RedmineNewIssueView::Patches::IssuesHelperPatch
    assert_includes IssuesHelper.included_modules, patch
    %i(link_to_issue render_descendants_tree issue_spent_hours_css_for
      issue_estimated_hours_css_for round_or_nill).each do |method|
        assert_includes IssuesHelper.instance_methods, method
      end
  end
end
