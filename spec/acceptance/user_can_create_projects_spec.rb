require 'rails_helper'

feature 'User can create projects', type: :request do
  scenario 'creating a project with success' do
    user = create_user
    ensure_user_is_allowed_to_create_project(user)

    expect do
      create_project_with('project' => { 'name' => 'Trilha de estudos' })
    end.to change { Project.count }.by(1)

    project_trilha = user.projects.reload.last
    expect(project_trilha.name).to eq('Trilha de estudos')

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(
      {
        'message' => 'Project "Trilha de estudos" has been created!'
      }
    )
  end

  scenario 'when user does not exist' do
    user = create_user
    ensure_user_is_allowed_to_create_project(user)

    ensure_user_does_not_exist(user)

    expect do
      create_project_with('project' => { 'name' => 'Trilha de estudos' })
    end.not_to change { Project.count }

    expect(response.status).to eq(403)
  end

  scenario 'when user is not allowed to create a project (in this case, user is not a manager)' do
    user = create_user
    ensure_user_is_allowed_to_create_project(user)

    ensure_user_is_not_manager(user)

    expect do
      create_project_with('project' => { 'name' => 'Trilha de estudos' })
    end.not_to change { Project.count }

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)).to eq(
      {
        'message' => 'Project could not be created!',
        'reason' => 'User must be a manager'
      }
    )
  end

  def create_user
    User.create!(login: 'rondy')
  end

  def ensure_user_is_allowed_to_create_project(user)
    user.update(role: 'manager')
    user.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user.id}", 0)
  end

  def ensure_user_does_not_exist(user)
    user.destroy
  end

  def ensure_user_is_not_manager(user)
    user.update(role: 'guest')
  end

  def create_project_with(params)
    post '/projects',
      params: params,
      headers: { 'ACCEPT' => 'application/json' }
  end
end
