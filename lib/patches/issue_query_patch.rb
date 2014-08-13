module NewIssueView
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        self.available_columns[0] = QueryColumn.new(:id, :sortable => "#{Issue.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => false)
      end
    end

    module InstanceMethods
    end
  end
end
# Add module to Query
IssueQuery.send(:include, NewIssueView::IssueQueryPatch)