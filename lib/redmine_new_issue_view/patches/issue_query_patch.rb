module RedmineNewIssueView
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          unloadable
          alias_method :statement_without_target_version_status, :statement
          alias_method :statement, :statement_with_target_version_status
          alias_method :available_filters_without_target_version_status,
            :available_filters
          alias_method :available_filters,
            :available_filters_with_target_version_status
          self.available_columns[0] = QueryColumn.new :id,
            sortable: "#{ Issue.table_name }.id", default_order: 'desc',
            caption: '#', frozen: false
        end
      end

      module InstanceMethods
        def statement_with_target_version_status
          filter  = filters.delete 'target_version_status'
          clauses = statement_without_target_version_status || ''
          if filter
            filters.merge!( 'target_version_status' => filter )
            op = operator_for('target_version_status')
            project_versions = Version.where project_id: project_id
            apply_filter = true
            table_name = Issue.table_name
            case op
            when '=', '!'
              version_status = value_for('target_version_status')
              if version_status == 'current'
                ids_list = [0]
                candidate_versions = []
                current_date = Date.today
                future_ending = project_versions.order(:effective_date)
                  .where('effective_date >= ?', current_date)
                  .select([:id, :effective_date])
                future_ending.each do |version|
                  version.custom_field_values.each do |custom_field|
                    if custom_field.custom_field.name == 'Start Date' &&
                      Date.parse(custom_field.value) <= current_date
                      candidate_versions << version
                    end
                  end
                end
                unless candidate_versions.blank?
                  ids_list << candidate_versions.min_by do |version|
                    version.effective_date
                  end.id
                end
              else
                ids_list = project_versions.where(status: version_status.clone)
                  .pluck(:id).push(0)
              end
            when '!*'
              ids_list = []
              apply_filter = false
              clauses << ' AND ' unless clauses.empty?
              clauses << "( #{ table_name }.fixed_version_id IS NULL ) "
            else
              ids_list = project_versions.pluck(:id).push(0)
            end
            ids_list << 0
            if apply_filter
              compare = op.eql?('!') ? 'NOT IN' : 'IN'
              ids_list = ids_list.join(', ')
              clauses << ' AND ' unless clauses.empty?
              clauses << "(#{ table_name }.fixed_version_id #{ compare } "
              clauses << "(#{ ids_list })) "
            end
          end
          clauses
        end

        def available_filters_with_target_version_status
          unless @available_filters
            available_filters_without_target_version_status.merge!({
              'target_version_status' => {
                name: l(:target_version_status),
                type: :list_optional,
                order: 7,
                values: Version::VERSION_STATUSES.map{|t| [t, t] } <<
                  ['current', 'current']
              }
            })
          end
          @available_filters
        end
      end
    end
  end
end

base = IssueQuery
patch = RedmineNewIssueView::Patches::IssueQueryPatch
base.send :include, patch unless base.included_modules.include? patch
