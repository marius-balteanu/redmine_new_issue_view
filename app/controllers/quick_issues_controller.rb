class QuickIssuesController < ApplicationController
  before_action :find_parent
  before_action :find_tracker
  before_action :find_assignee

  def add
    @issue = Issue.new(issue_params)
    if @issue.save
      render json: { success: 'Success!' }
    else
      render json: { error: @issue.errors.full_messages }, status: 400
    end
  end

  private

  def issue_params
    @issue_params ||= {
      assigned_to_id:  @assignee.id,
      author_id:       User.current.id,
      estimated_hours: data[:estimation],
      parent_id:       @parent.id,
      project_id:      @parent.project_id,
      subject:         data[:subject],
      tracker_id:      @tracker.id
    }
  end

  def data
    @data ||= params[:data]
  end

  def find_parent
    @parent = Issue.where(id: params[:parent]).first
    unless @parent
      render json: { error: 'Parent issue not found' }, status: 400
    end
  end

  def find_tracker
    trackers = Tracker.where('name LIKE ?', "#{data[:tracker]}%").limit(2).to_a
    if trackers.size == 0
      render json: { error: 'No matching tracker found' }, status: 400
    elsif trackers.size == 2
      render json: { error: 'More than one tracker found' }, status: 400
    else
      @tracker = trackers.first
    end
  end

  def find_assignee
    @assignee = User.where(login: data[:assignee]).first
    unless @assignee
      render json: { error: 'Assignee not found' }, status: 400
    end
  end
end
