class IssueViewHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    controller = context[:controller]
    controller.render_to_string partial: 'new_issue_view/header_assets'
  end
end
