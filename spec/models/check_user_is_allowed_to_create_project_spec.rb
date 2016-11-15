require 'rails_helper'

describe CheckUserIsAllowedToCreateProject do
  it 'is allowed when all rules are obeyed' do
    user = create_user
    ensure_all_rules_for_create_project_are_obeyed(user)

    checking_result = perform_check(user)

    expect(checking_result.is_allowed?).to be(true)
    expect(checking_result.error_reason).to be(nil)
  end

  it 'is not allowed when user is not manager' do
    user = create_user
    ensure_all_rules_for_create_project_are_obeyed(user)

    ensure_user_is_not_manager(user)

    checking_result = perform_check(user)

    expect(checking_result.is_allowed?).to be(false)
    expect(checking_result.error_reason).to eq(:user_must_be_a_manager)
  end

  it 'is not allowed when user is beyond the "projects count limit" rule' do
    user = create_user
    ensure_all_rules_for_create_project_are_obeyed(user)

    ensure_user_is_beyond_the_projects_count_limit_rule(user)

    checking_result = perform_check(user)

    expect(checking_result.is_allowed?).to be(false)
    expect(checking_result.error_reason).to eq(:user_must_be_within_the_projects_count_limit_rule)
  end

  it 'is not allowed when the project creation config is blocked' do
    user = create_user
    ensure_all_rules_for_create_project_are_obeyed(user)

    ensure_project_creation_config_is_blocked(user)

    checking_result = perform_check(user)

    expect(checking_result.is_allowed?).to be(false)
    expect(checking_result.error_reason).to eq(:project_creation_config_must_be_no_blocked)
  end

  def create_user
    User.create!(login: 'rondy')
  end

  def ensure_all_rules_for_create_project_are_obeyed(user)
    ensure_user_is_manager(user)
    ensure_user_is_not_beyond_the_projects_count_limit_rule(user)
    ensure_project_creation_config_is_not_blocked(user)
  end

  def ensure_user_is_manager(user)
    ensure_user_has_role(user, 'manager')
  end

  def ensure_user_is_not_manager(user)
    ensure_user_has_role(user, 'guest')
  end

  def ensure_user_has_role(user, role)
    user.update(role: role)
  end

  def ensure_user_is_not_beyond_the_projects_count_limit_rule(user)
    user.projects.delete_all
  end

  def ensure_user_is_beyond_the_projects_count_limit_rule(user)
    5.times { |number| user.projects.create!(name: "Projeto ##{number}") }
  end

  def ensure_project_creation_config_is_not_blocked(user)
    Redis.new.set("projects_creation_blocked:user_#{user.id}", 0)
  end

  def ensure_project_creation_config_is_blocked(user)
    Redis.new.set("projects_creation_blocked:user_#{user.id}", 1)
  end

  def perform_check(user)
    CheckUserIsAllowedToCreateProject.new.call(user)
  end

  describe described_class::Validator do
    it 'returns a valid result when all the rules are obeyed' do
      valid_user = double(
        manager?: true,
        beyond_the_projects_count_limit_rule?: false,
        project_creation_config_is_blocked?: false
      )

      validator = described_class.new(user: valid_user)

      expect(validator.valid?).to be(true)
      expect(validator.error_reason).to be(nil)
    end

    it 'returns a invalid result when one of the rules are not obeyed' do
      invalid_user = double(
        manager?: false,
        beyond_the_projects_count_limit_rule?: false,
        project_creation_config_is_blocked?: false
      )

      validator = described_class.new(user: invalid_user)

      expect(validator.valid?).to be(false)
      expect(validator.error_reason).to be(:user_must_be_a_manager)
    end
  end
end
