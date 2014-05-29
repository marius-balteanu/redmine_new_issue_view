require 'redmine'

class ViewIssueViewListener < Redmine::Hook::ViewListener

  # Adds javascript
  def view_layouts_base_html_head(context)
    javascript_include_tag('view_issue.js', :plugin => :redmine_new_issue_view)
  end

end
