ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/redmine_new_issue_view/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) << paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_new_issue_view do
  name 'New Issue View'
  author 'Zitec'
  description 'Overrides for redmine templates and methods'
  version '1.0.1'
  url 'https://github.com/sdwolf/redmine_new_issue_view'
  author_url 'http://www.zitec.com'
end
