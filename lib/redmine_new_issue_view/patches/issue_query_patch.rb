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

base = IssueQuery
new_module = NewIssueView::Patches::IssueQueryPatch
base.send :include, new_module unless base.included_modules.include? new_module
