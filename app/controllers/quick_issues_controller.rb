class QuickIssuesController < ApplicationController
  def add
    @parent = Issue.find(params[:parent])
    data = params[:data]
    trackers = Tracker.where("name LIKE ?", "#{data[:tracker]}%").to_a
    if trackers.size == 0
      render json: { error: 'No matching tracker found' }, status: 400
      return
    elsif trackers.size > 1
      render json: { error: 'More than one tracker found' }, status: 400
      return
    else
      @tracker = trackers.first
    end
    @assignee = User.where(login: data[:assignee]).first
    unless @assignee
      render json: { error: 'Assignee not found' }, status: 400
      return
    end
    @issue = Issue.new parent_id: @parent.id, subject: data[:subject],
      tracker_id: @tracker.id, project_id: @parent.project_id,
      author_id: User.current.id, estimated_hours: data[:estimation],
      assigned_to_id: @assignee.id
    if @issue.save
      render json: { success: 'Success!' }
    else
      render json: { error: @issue.errors.full_messages }, status: 400
    end
  end
end
