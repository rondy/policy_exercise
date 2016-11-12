require 'rails_helper'

feature 'User can create projects', type: :request do
  scenario 'creating a project with success' do
    headers = {
      'ACCEPT' => 'application/json'
    }

    expect do
      post '/projects',
        params: { 'project' => { 'name' => 'Trilha de estudos' } },
        headers: headers
    end.to change { Project.count }.by(1)

    user_rondy = User.where(login: 'rondy').first!
    expect(user_rondy).to be_present

    project_trilha = user_rondy.projects.last
    expect(project_trilha.name).to eq('Trilha de estudos')

    expect(JSON.parse(response.body)).to eq(
      {
        'message' => 'Project "Trilha de estudos" has been created!'
      }
    )
  end
end
