class ProjectsController < ApplicationController
  def create
    current_user = User.where(login: 'rondy').first

    unless current_user
      head 403
      return
    end

    unless current_user.role == 'manager'
      json_response = {
        'message' => 'Project could not be created!',
        'reason' => 'User must be a manager'
      }

      respond_to do |format|
        format.json { render inline: json_response.to_json, status: 422 }
      end

      return
    end

    if current_user.projects.count >= 5
      json_response = {
        'message' => 'Project could not be created!',
        'reason' => 'User can only create 5 projects'
      }

      respond_to do |format|
        format.json { render inline: json_response.to_json, status: 422 }
      end

      return
    end

    created_project =
      current_user.projects.create!(
        params.require(:project).permit(:name)
      )

    json_response = {
      message: "Project \"#{created_project.name}\" has been created!"
    }

    respond_to do |format|
      format.json { render inline: json_response.to_json }
    end
  end
end
