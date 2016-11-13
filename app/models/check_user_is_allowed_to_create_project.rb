class CheckUserIsAllowedToCreateProject
  def call(user)
    if user_is_not_manager?(user)
      {
        is_allowed: false,
        error_reason: :user_must_be_a_manager
      }
    elsif user_is_beyond_the_projects_count_limit_rule?(user)
      {
        is_allowed: false,
        error_reason: :user_must_be_within_the_projects_count_limit_rule
      }
    elsif project_creation_config_is_blocked?(user)
      {
        is_allowed: false,
        error_reason: :project_creation_config_must_be_no_blocked
      }
    else
      {
        is_allowed: true,
        error_reason: nil
      }
    end
  end

  private

  def user_is_not_manager?(user)
    !user.manager?
  end

  def user_is_beyond_the_projects_count_limit_rule?(user)
    user.beyond_the_projects_count_limit_rule?
  end

  def project_creation_config_is_blocked?(user)
    user.project_creation_config_is_blocked?
  end
end
