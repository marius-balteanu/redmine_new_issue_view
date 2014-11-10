module NewIssueView
  module IssueQueryPatch
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable
        self.available_columns[0] = QueryColumn.new(
          :id, :sortable => "#{Issue.table_name}.id", :default_order => 'desc',
          :caption => '#', :frozen => false
        )
      end
    end

    module InstanceMethods
    end
  end
end

unless IssueQuery.included_modules.include? NewIssueView::IssueQueryPatch
  IssueQuery.send :include, NewIssueView::IssueQueryPatch
end
