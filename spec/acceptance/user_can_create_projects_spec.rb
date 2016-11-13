require 'rails_helper'

feature 'User can create projects', type: :request do
  scenario 'creating a project with success' do
    headers = {
      'ACCEPT' => 'application/json'
    }

    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'manager')
    user_rondy.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 0)

    expect do
      post '/projects',
        params: { 'project' => { 'name' => 'Trilha de estudos' } },
        headers: headers
    end.to change { Project.count }.by(1)

    user_rondy = User.where(login: 'rondy').first!
    expect(user_rondy).to be_present

    project_trilha = user_rondy.projects.last
    expect(project_trilha.name).to eq('Trilha de estudos')

    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(
      {
        'message' => 'Project "Trilha de estudos" has been created!'
      }
    )
  end

  scenario 'when user does not exist' do
    headers = {
      'ACCEPT' => 'application/json'
    }

    expect do
      post '/projects',
        params: { 'project' => { 'name' => 'Trilha de estudos' } },
        headers: headers
    end.not_to change { Project.count }

    expect(response.status).to eq(403)
  end

  scenario 'when user is not allowed to create a project (in this case, user is not a manager)' do
    headers = {
      'ACCEPT' => 'application/json'
    }

    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'guest')
    user_rondy.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 0)

    expect do
      post '/projects',
        params: { 'project' => { 'name' => 'Trilha de estudos' } },
        headers: headers
    end.not_to change { Project.count }

    expect(response.status).to eq(422)
    expect(JSON.parse(response.body)).to eq(
      {
        'message' => 'Project could not be created!',
        'reason' => 'User must be a manager'
      }
    )
  end
end
