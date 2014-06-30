module IssuesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development

      #alias_method_chain :available_filters, :parent_id
    end
  end

  module InstanceMethods

    def render_descendants_tree_status(issue)
      s = '<form><table class="list issues">'
      issue_list(issue.descendants.visible.sort_by(&:lft)) do |child, level|
        css = "issue issue-#{child.id} status-#{child.status.id} hascontextmenu"
        css << " idnt idnt-#{level}" if level > 0
        s << content_tag('tr',
                         content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
                             content_tag('td', modified_link_to_issue(child, :truncate => 60, :project => (issue.project_id != child.project_id)), :class => 'subject') +
                             content_tag('td', content_tag('span', h(child.status)), :class => 'status') +
                             content_tag('td', link_to_user(child.assigned_to)) +
                             content_tag('td', progress_bar(child.done_ratio, :width => '80px')),
                         :class => css)
      end
      s << '</table></form>'
      s.html_safe
    end

    def modified_link_to_issue(issue, options={})
      title = nil
      subject = nil
      text = options[:tracker] == false ? "##{issue.id}" : "#{issue.tracker} ##{issue.id}:"
      if options[:subject] == false
        title = issue.subject.truncate(60)
      else
        subject = issue.subject
        if truncate_length = options[:truncate]
          subject = subject.truncate(truncate_length)
        end
      end
      only_path = options[:only_path].nil? ? true : options[:only_path]
      s = link_to(text, issue_path(issue, :only_path => only_path),
                  :class => issue.css_classes, :title => title)
      s << h(" #{subject}") if subject
      s = h("#{issue.project} - ") + s if options[:project]
      s
    end
  end
end

# Add module to Query
IssuesHelper.send(:include, IssuesHelperPatch)