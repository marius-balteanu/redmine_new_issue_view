module NewIssueView
  module IssuesHelperPatch
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        unloadable
      end
    end

    module InstanceMethods
      require_relative '../../app/helpers/issues_helper'
    end
  end
end

unless IssuesHelper.included_modules.include? NewIssueView::IssuesHelperPatch
  IssuesHelper.send :include, NewIssueView::IssuesHelperPatch
end
