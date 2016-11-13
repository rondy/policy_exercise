class CheckUserIsAllowedToCreateProject
  def call(user)
    if !user_is_manager?(user)
      {
        is_allowed: false,
        error_reason: 'User must be a manager'
      }
    elsif user.projects.count >= 5
      {
        is_allowed: false,
        error_reason: 'User can only create 5 projects'
      }
    elsif Redis.new.get("projects_creation_blocked:user_#{user.id}").to_s == '1'
      {
        is_allowed: false,
        error_reason: 'The project creation config is blocked for this user'
      }
    else
      {
        is_allowed: true,
        error_reason: nil
      }
    end
  end

  private

  def user_is_manager?(user)
    user.manager?
  end
end