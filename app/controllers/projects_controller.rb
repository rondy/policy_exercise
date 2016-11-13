class ProjectsController < ApplicationController
  before_action :ensure_current_user_exists!

  def create
    checking_result = check_user_is_allowed_to_create_project(current_user)

    unless checking_result[:is_allowed]
      render_failed_permission_for_project_creation(
        checking_result[:error_reason]
      )

      return
    end

    created_project =
      create_project_for_user(
        current_user,
        params.require(:project).permit(:name)
      )

    render_successful_project_creation(created_project)
  end

  private

  def ensure_current_user_exists!
    head 403 unless current_user
  end

  def current_user
    @current_user ||= User.where(login: 'rondy').first
  end

  def check_user_is_allowed_to_create_project(user)
    CheckUserIsAllowedToCreateProject.new.call(user)
  end

  def create_project_for_user(user, project_params)
    user.projects.create!(project_params)
  end

  def render_successful_project_creation(created_project)
    json_response = {
      message: "Project \"#{created_project.name}\" has been created!"
    }

    respond_to do |format|
      format.json { render inline: json_response.to_json }
    end
  end

  def render_failed_permission_for_project_creation(error_reason)
    json_response = {
      'message' => 'Project could not be created!',
      'reason' => error_reason
    }

    respond_to do |format|
      format.json { render inline: json_response.to_json, status: 422 }
    end
  end
end
