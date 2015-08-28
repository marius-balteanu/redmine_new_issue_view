module NewIssueView
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable

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
            text << ": #{ subject }" if subject
            only_path = options[:only_path].nil? ? true : options[:only_path]
            s = link_to(text, issue_url(issue, :only_path => only_path),
                        :class => issue.css_classes, :title => title)
            s = h("#{issue.project} - ") + s if options[:project]
            s
          end

          def render_descendants_tree(issue)
            s = '<form><table class="list issues">'
            issue_list(issue.descendants.visible.preload(:status, :priority, :tracker).sort_by(&:lft)) do |child, level|
              css = "issue issue-#{child.id} hascontextmenu"
              css << " idnt idnt-#{level}" if level > 0
              s << content_tag('tr',
                     content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
                     content_tag('td', link_to_issue(child, :project => (issue.project_id != child.project_id)), :class => 'subject', :style => 'width: 50%') +
                     content_tag('td', h(child.status)) +
                     content_tag('td', link_to_user(child.assigned_to)) +
                     content_tag('td', progress_bar(child.done_ratio, :width => '80px')),
                     :class => css)
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
