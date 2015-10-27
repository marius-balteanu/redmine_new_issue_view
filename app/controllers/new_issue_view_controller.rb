class NewIssueViewController < ApplicationController
  before_filter :find_project

  def parents
    @issues = []
    q = (params[:q] || params[:term]).to_s.strip
    if q.present?
      scope = Issue.cross_project_scope(@project, params[:scope]).visible
      if q.match(/\A#?(\d+)\z/)
        @issues << scope.joins(:status).select(:id, :subject, :tracker_id, :status_id, "#{IssueStatus.table_name}.name").find_by_id($1.to_i)
      else
        @issues += scope.joins(:status).select(:id, :subject, :tracker_id, :status_id, "#{IssueStatus.table_name}.name").where("LOWER(#{Issue.table_name}.subject) LIKE LOWER(?)", "%#{q}%").order("#{Issue.table_name}.id DESC").limit(10).to_a
      end
      @issues.compact!
    end
    render json: @issues.group_by {|i| i.tracker.name}
  end

  private

  def find_project
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
