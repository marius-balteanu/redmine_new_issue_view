ActiveSupport::Reloader.to_prepare do
  paths = '/lib/redmine_new_issue_view/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) << paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_new_issue_view do
  name 'New Issue View'
  author 'Zitec'
  description 'Overrides for redmine templates and methods'
  version '3.2.0'
  url 'https://github.com/marius-balteanu/redmine_new_issue_view'
  author_url 'http://www.zitec.com'
end

Rails.application.config.after_initialize do
  test_dependencies = { redmine_testing_gems: '1.1.1' }
  current_plugin = Redmine::Plugin.find :redmine_new_issue_view
  check_dependencies = proc do |plugin, version|
    begin
      current_plugin.requires_redmine_plugin plugin, version
    rescue Redmine::PluginNotFound => error
      raise Redmine::PluginNotFound,
        "New Issue View depends on plugin: " \
          "#{ plugin } version: #{ version }"
    end
  end
  test_dependencies.each &check_dependencies if Rails.env.test?
end
