class IssueViewHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    javascript_include_tag('new_issue_view', plugin: :redmine_new_issue_view) +
    stylesheet_link_tag('new_issue_view', plugin: :redmine_new_issue_view)
  end
end
