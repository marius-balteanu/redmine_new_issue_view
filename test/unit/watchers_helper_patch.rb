require File.expand_path '../../test_helper', __FILE__

class WatchersHelperPatchTest < ActiveSupport::TestCase
  test 'WatchersHelper is patched' do
    patch = RedmineNewIssueView::Patches::WatchersHelperPatch
    assert_includes WatchersHelper.included_modules, patch
    %i(watcher_link_without_span watcher_link_with_span).each do |method|
        assert_includes WatchersHelper.instance_methods, method
      end
  end
end
