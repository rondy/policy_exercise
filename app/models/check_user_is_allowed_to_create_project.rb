class CheckUserIsAllowedToCreateProject
  include Contracts::Core
  include Contracts::Builtin

  class PermissionCheckResult
    include Contracts::Core
    include Contracts::Builtin

    def self.valid?(val)
      val.respond_to?(:is_allowed?) && val.respond_to?(:error_reason)
    end

    def self.build_allowed_permission
      self.new(is_allowed: true)
    end

    def self.build_denied_permission(error_reason:)
      self.new(is_allowed: false, error_reason: error_reason)
    end

    def initialize(is_allowed:, error_reason: nil)
      @is_allowed = is_allowed
      @error_reason = error_reason
    end

    Contract None => Bool
    def is_allowed?
      !!@is_allowed
    end

    Contract None => Maybe[Symbol]
    def error_reason
      @error_reason
    end
  end

  UserOnPermissionContext =
    RespondTo[
      :manager?,
      :beyond_the_projects_count_limit_rule?,
      :project_creation_config_is_blocked?
    ]

  Contract UserOnPermissionContext => PermissionCheckResult
  def call(user)
    validator = build_validator_for(user)

    if validator.valid?
      build_result_for_allowed_permission
    else
      build_result_for_denied_permission(
        error_reason: validator.error_reason
      )
    end
  end

  private

  def build_validator_for(user)
    Validator.new(user: user)
  end

  def build_result_for_allowed_permission
    PermissionCheckResult.build_allowed_permission
  end

  def build_result_for_denied_permission(error_reason:)
    PermissionCheckResult.build_denied_permission(error_reason: error_reason)
  end

  class Validator
    include ActiveModel::Model

    attr_accessor :user

    validate :user_must_be_manager
    validate :user_must_be_within_the_projects_count_limit_rule
    validate :project_creation_config_must_be_no_blocked

    def error_reason
      self.errors.to_a.first.try(:to_sym)
    end

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
