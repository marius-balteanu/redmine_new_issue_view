require_dependency 'issues_helper'

module NewIssueView
  module Patches
    module IssuesHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable

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
                        :class => issue.css_classes + ' list_title', :title => title)
            s << link_to(" #{subject}", issue_path(issue, :only_path => only_path), :title => title ) if subject
            s = h("#{issue.project} - ") + s if options[:project]
            s
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
        end
      end
    end
  end
end

unless IssuesHelper.included_modules.include? NewIssueView::Patches::IssuesHelperPatch
  IssuesHelper.send :include, NewIssueView::Patches::IssuesHelperPatch
end
