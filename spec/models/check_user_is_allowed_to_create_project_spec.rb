require 'rails_helper'

describe CheckUserIsAllowedToCreateProject do
  it 'is allowed when all rules are obeyed' do
    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'manager')
    user_rondy.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 0)

    checking_result = CheckUserIsAllowedToCreateProject.new.call(user_rondy)

    expect(checking_result[:is_allowed]).to be(true)
    expect(checking_result[:error_reason]).to be(nil)
  end

  it 'is not allowed when user is not manager' do
    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'guest')
    user_rondy.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 0)

    checking_result = CheckUserIsAllowedToCreateProject.new.call(user_rondy)

    expect(checking_result[:is_allowed]).to be(false)
    expect(checking_result[:error_reason]).to eq('User must be a manager')
  end

  it 'is not allowed when user is beyond the "projects count limit" rule' do
    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'manager')
    5.times { |number| user_rondy.projects.create!(name: "Projeto ##{number}") }
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 0)

    checking_result = CheckUserIsAllowedToCreateProject.new.call(user_rondy)

    expect(checking_result[:is_allowed]).to be(false)
    expect(checking_result[:error_reason]).to eq('User can only create 5 projects')
  end

  it 'is not allowed when when the project creation config is blocked' do
    user_rondy = User.create!(login: 'rondy')
    user_rondy.update(role: 'manager')
    user_rondy.projects.delete_all
    Redis.new.set("projects_creation_blocked:user_#{user_rondy.id}", 1)

    checking_result = CheckUserIsAllowedToCreateProject.new.call(user_rondy)

    expect(checking_result[:is_allowed]).to be(false)
    expect(checking_result[:error_reason]).to eq('The project creation config is blocked for this user')
  end
end
