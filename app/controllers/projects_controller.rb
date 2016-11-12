class ProjectsController < ApplicationController
  before_action :ensure_current_user_exists!

  def create
    checking_result = check_user_is_allowed_to_create_project(current_user)

    if checking_result[:is_allowed]
      created_project =
        current_user.projects.create!(
          params.require(:project).permit(:name)
        )

      render_successful_project_creation(created_project)
    else
      json_response = {
        'message' => 'Project could not be created!',
        'reason' => checking_result[:error_reason]
      }

      respond_to do |format|
        format.json { render inline: json_response.to_json, status: 422 }
      end
    end
  end

  def render_successful_project_creation(created_project)
    json_response = {
      message: "Project \"#{created_project.name}\" has been created!"
    }

    respond_to do |format|
      format.json { render inline: json_response.to_json }
    end
  end

  private

  def ensure_current_user_exists!
    head 403 unless current_user
  end

  def current_user
    @current_user ||= User.where(login: 'rondy').first
  end

  def check_user_is_allowed_to_create_project(current_user)
    checking_result = {}

    checking_result[:is_allowed] = true

    unless current_user.role == 'manager'
      checking_result[:is_allowed] = false
      checking_result[:error_reason] = 'User must be a manager'
    end

    if current_user.projects.count >= 5
      checking_result[:is_allowed] = false
      checking_result[:error_reason] = 'User can only create 5 projects'
    end

    if Redis.new.get("projects_creation_blocked:user_#{current_user.id}").to_s == '1'
      checking_result[:is_allowed] = false
      checking_result[:error_reason] = 'The project creation config is blocked for this user'
    end

    checking_result
  end
end
