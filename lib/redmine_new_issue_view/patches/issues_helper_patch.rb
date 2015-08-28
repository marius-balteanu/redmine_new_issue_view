module NewIssueView
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable

          # This overrides the link_to_issue method from ApplicationHeler
          # For some reason I can only override it here...
          def link_to_issue(issue, options = {})
            title = nil
            subject = nil
            text = options[:tracker] == false ? "##{issue.id}" : "#{issue.tracker} ##{issue.id}"
            if options[:subject] == false
              title = issue.subject.truncate(60)
            else
              subject = issue.subject
              if truncate_length = options[:truncate]
                subject = subject.truncate(truncate_length)
              end
            end
            # The subject is added at the end of the text
            text << ": #{ subject }" if subject
            only_path = options[:only_path].nil? ? true : options[:only_path]
            s = link_to(text, issue_url(issue, :only_path => only_path),
                        :class => issue.css_classes, :title => title)
            s = h("#{issue.project} - ") + s if options[:project]
            s
          end

          # This overrides the render_descendants_tree method from IssuesHelper
          # It ads the thead section and changes the listed columns
          def render_descendants_tree(issue)
            s = "<form><table class='list issues'>
              <thead>
                <tr>
                  <th>#{ link_to image_tag('toggle_check.png'), {},
                                        :onclick => 'toggleIssuesSelection(this); return false;',
                                        :title => "#{l(:button_check_all)}/#{l(:button_uncheck_all)}" }</th>
                  <th>#{ t 'views.table_headers.subject' }</th>
                  <th>#{ t 'views.table_headers.status' }</th>
                  <th>#{ t 'views.table_headers.assignee' }</th>
                  <th>#{ t 'views.table_headers.estimated' }</th>
                  <th>#{ t 'views.table_headers.spent' }</th>
                </tr>
              </thead>"
            issue_list(issue.descendants.visible.preload(:status, :priority, :tracker).sort_by(&:lft)) do |child, level|
              css_class = "issue issue-#{child.id} hascontextmenu"
              css_class << " idnt idnt-#{level}" if level > 0
              estimated_hours = round_or_nill child.estimated_hours, 2
              if estimated_hours || child.total_spent_hours != 0
                total_spent_hours = round_or_nill child.total_spent_hours, 2
              end
              estimated_hours_css = issue_estimated_hours_css_for estimated_hours, total_spent_hours
              spent_hours_css = issue_spent_hours_css_for estimated_hours, total_spent_hours
              s << content_tag('tr',
                     content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
                     content_tag('td', link_to_issue(child, :project => (issue.project_id != child.project_id)), :class => 'subject', :style => 'width: 50%') +
                     content_tag('td', h(child.status)) +
                     content_tag('td', link_to_user(child.assigned_to)) +
                     # These columns were added
                     content_tag('td', estimated_hours, class: "estimated #{ estimated_hours_css }") +
                     content_tag('td', total_spent_hours, class: "spent #{ spent_hours_css }"),
                     # This column was removed
                     # content_tag('td', progress_bar(child.done_ratio, :width => '80px')),
                     :class => css_class)
            end
            s << '</table></form>'
            s.html_safe
          end

          def issue_spent_hours_css_for(estimated_hours, spent_hours)
            return '' unless estimated_hours && spent_hours
            case
            when spent_hours > estimated_hours
              'hours_overdue'
            when spent_hours == estimated_hours
              'hours_complete'
            else
              'hours_on_schedule'
            end
          end

          def issue_estimated_hours_css_for(estimated_hours, spent_hours)
            return '' unless (estimated_hours && spent_hours) && (spent_hours == estimated_hours)
            'hours_complete'
          end

          def round_or_nill(value, decimals)
            return unless value
            value.to_f.round decimals
          end
        end
      end
    end
  end
end

base = IssuesHelper
new_module = NewIssueView::Patches::IssuesHelperPatch
base.send :include, new_module unless base.included_modules.include? new_module
