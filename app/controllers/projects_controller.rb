class ProjectsController < ApplicationController
  def create
    current_user = User.where(login: 'rondy').first

    unless current_user
      head 403
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
