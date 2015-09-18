# Code coverage setup
require 'simplecov'
SimpleCov.start do
  add_group 'Hooks', 'lib/redmine_new_issue_view/hooks'
  add_group 'Patches', 'lib/redmine_new_issue_view/patches'
  add_filter '/test/'
  add_filter 'init.rb'
  root File.expand_path(File.dirname(__FILE__) + '/../')
  coverage_dir 'tmp/coverage'
end

# Load the Redmine helper
require File.expand_path File.dirname(__FILE__) << '/../../../test/test_helper'
