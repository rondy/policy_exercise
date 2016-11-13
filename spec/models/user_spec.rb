require 'rails_helper'

describe User do
  it 'is a manager when role is "manager"' do
    user = build_valid_user(role: 'manager')

    expect(user.manager?).to be(true)
  end

  it 'is not a manager when role is other than "manager"' do
    user = build_valid_user(role: 'guest')

    expect(user.manager?).to be(false)
  end

  describe '#beyond_the_projects_count_limit_rule?' do
    it 'is true when projects count is greater than five projects' do
      user = create_valid_user

      5.times { |number| user.projects.create!(name: "Projeto ##{number}") }
      expect(user.beyond_the_projects_count_limit_rule?).to be(true)
    end

    it 'is false when projects count is less than five projects' do
      user = create_valid_user

      user.projects.destroy_all
      expect(user.beyond_the_projects_count_limit_rule?).to be(false)

      4.times { |number| user.projects.create!(name: "Projeto ##{number}") }
      expect(user.beyond_the_projects_count_limit_rule?).to be(false)
    end
  end

  describe '#project_creation_config_is_blocked?' do
    it 'is true when the config is marked as blocked for the given user' do
      user = create_valid_user
      mark_project_creation_config_as_blocked(user)

      expect(user.project_creation_config_is_blocked?).to be(true)
    end

    it 'is false when the config is marked as no blocked for the given user' do
      user = create_valid_user
      mark_project_creation_config_as_no_blocked(user)

      expect(user.project_creation_config_is_blocked?).to be(false)
    end
  end

  def create_valid_user
    build_valid_user.tap(&:save!)
  end

  def build_valid_user(attributes = {})
    User.new({ login: 'rondy', role: 'manager' }.merge(attributes))
  end

  def mark_project_creation_config_as_blocked(user)
    Redis.new.set("projects_creation_blocked:user_#{user.id}", 1)
  end

  def mark_project_creation_config_as_no_blocked(user)
    Redis.new.set("projects_creation_blocked:user_#{user.id}", 0)
  end
end
