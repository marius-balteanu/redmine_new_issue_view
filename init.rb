require 'issue_view_listener'
require 'patches/issue_helper_patch'

Redmine::Plugin.register :redmine_new_issue_view do
  name 'Redmine New Issue View plugin'
  author 'Zitec'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.zitec.com'
  author_url 'http://www.zitec.com'
end