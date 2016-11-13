class PresentFailedPermissionForProjectCreation
  def call(error_reason)
    case error_reason
    when :user_must_be_a_manager
      'User must be a manager'
    when :user_must_be_within_the_projects_count_limit_rule
      'User can only create 5 projects'
    when :project_creation_config_must_be_no_blocked
      'The project creation config is blocked for this user'
    else
      ''
    end
  end
end
