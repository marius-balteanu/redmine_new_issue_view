module NewIssueView
  module QueriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        #alias_method_chain :available_filters, :parent_id
        alias_method_chain :column_value, :issue_id
      end
    end

    module InstanceMethods
      def column_value_with_issue_id(column, issue, value)
          case column.name
          when :id
            link_to value, issue_path(issue)
          when :subject
            link_to value + " (#{issue.id})", issue_path(issue)
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
# Add module to Query
QueriesHelper.send(:include, NewIssueView::QueriesHelperPatch)