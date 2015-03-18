require_dependency 'issue_query'

module NewIssueView
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.class_eval do
          unloadable
          self.available_columns[0] = QueryColumn.new(
            :id, :sortable => "#{Issue.table_name}.id", :default_order => 'desc',
            :caption => '#', :frozen => false
          )
        end
      end
    end
  end
end

unless IssueQuery.included_modules.include? NewIssueView::Patches::IssueQueryPatch
  IssueQuery.send :include, NewIssueView::Patches::IssueQueryPatch
end
