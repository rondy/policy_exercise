class CheckUserIsAllowedToCreateProject
  def call(user)
    validator = build_validator_for(user)

    if validator.valid?
      build_result_for_allowed_permission
    else
      error_reason = extract_error_reason_from(validator)

      build_result_for_denied_permission(
        error_reason: error_reason
      )
    end
  end

  private

  def build_validator_for(user)
    Validator.new(user: user)
  end

  def extract_error_reason_from(validator)
    validator.errors.to_a.first.to_sym
  end

  def build_result_for_allowed_permission
    OpenStruct.new(
      is_allowed?: true,
      error_reason: nil
    )
  end

  def build_result_for_denied_permission(error_reason:)
    OpenStruct.new(
      is_allowed?: false,
      error_reason: error_reason
    )
  end

  class Validator
    include ActiveModel::Model

    attr_accessor :user

    validate :user_must_be_manager
    validate :user_must_be_within_the_projects_count_limit_rule
    validate :project_creation_config_must_be_no_blocked

    private

    def user_must_be_manager
      if !user.manager?
        errors.add(:base, 'user_must_be_a_manager')
      end
    end

    def user_must_be_within_the_projects_count_limit_rule
      if user.beyond_the_projects_count_limit_rule?
        errors.add(:base, 'user_must_be_within_the_projects_count_limit_rule')
      end
    end

    def project_creation_config_must_be_no_blocked
      if user.project_creation_config_is_blocked?
        errors.add(:base, 'project_creation_config_must_be_no_blocked')
      end
    end
  end
end
