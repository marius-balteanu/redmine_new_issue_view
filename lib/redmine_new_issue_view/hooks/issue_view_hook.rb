class IssueViewHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    controller = context[:controller]
    result = controller.render_to_string partial: 'new_issue_view/header_assets'
  end

  def view_issues_show_details_bottom(context)
    issue = context[:issue]
    if Redmine::Plugin.installed?(:redmine_restrict_tracker)
      can_have_children = issue.can_have_children?
      result = '<input type="hidden" id="can-have-children" value="' + can_have_children.to_s + '">'
      if can_have_children
        result + '<input type="hidden" id="available-children" value="' + h(issue.available_children.to_s) + '">'
      end
    else
      ''
    end
  end
end
