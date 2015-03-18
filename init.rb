require 'redmine'

# Patches to the Redmine core.
ActionDispatch::Callbacks.to_prepare do
  Dir[File.dirname(__FILE__) + '/lib/new_issue_view/patches/*_patch.rb'].each do |file|
    require_dependency file
  end

  Dir[File.dirname(__FILE__) + '/lib/new_issue_view/hooks/*_hook.rb'].each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_new_issue_view do
  name 'Redmine New Issue View plugin'
  author 'Zitec'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.zitec.com'
  author_url 'http://www.zitec.com'
end
