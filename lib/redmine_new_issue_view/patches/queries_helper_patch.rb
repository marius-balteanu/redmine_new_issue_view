module NewIssueView
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          unloadable
          alias_method_chain :column_value, :issue_id
        end
      end

      module InstanceMethods
        def column_value_with_issue_id(column, issue, value)
          case column.name
          when :id
            link_to value, issue_path(issue)
          when :subject
            link_to_issue issue, tracker: false
          when :parent
            value ? (value.visible? ? link_to_issue(value, :subject => false) : "##{value.id}") : ''
          when :spent_hours
            issue.total_spent_hours
          when :description
            issue.description? ? content_tag('div', textilizable(issue, :description), :class => "wiki") : ''
          when :done_ratio
            progress_bar(value, :width => '80px')
          when :updated_on
            time_tag(value) + ' ago'
          when :relations
            other = value.other_issue(issue)
            content_tag('span',
              (l(value.label_for(issue)) + " " + link_to_issue(other, :subject => false, :tracker => false)).html_safe,
              :class => value.css_classes_for(issue))
          else
            format_object(value)
          end
        end
      end
    end
  end
end

base = QueriesHelper
new_module = NewIssueView::Patches::QueriesHelperPatch
base.send :include, new_module unless base.included_modules.include? new_module
