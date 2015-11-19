class IssueViewHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    controller = context[:controller]
    result = controller.render_to_string partial: 'new_issue_view/header_assets'
    if controller.is_a? IssuesController
      settings = Setting.plugin_redmine_new_issue_view
      return result if !settings || settings.blank?
      field_id = settings['custom_field_id']
      preference = CustomValue.where(customized_type: 'Principal',
        customized_id: User.current.id, custom_field_id: field_id).first
      return result if !preference || !preference.value
      partial = 'issue_view_' << preference.value.downcase.split(' ').join('_') << '.css'
      result << controller.render_to_string(
          partial: 'new_issue_view/user_specific_assets',
          locals: { file: partial })
    end
    result
  end

  def view_issues_show_details_bottom(context)
    issue = context[:issue]
    if Redmine::Plugin.installed?(:redmine_restrict_tracker)
      '<input type="hidden" id="can-have-children" value="' + issue.can_have_children?.to_s + '">'
    else
      ''
    end
  end
end
