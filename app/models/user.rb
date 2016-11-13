class User < ApplicationRecord
  has_many :projects

  def manager?
    role == 'manager'
  end

  def beyond_the_projects_count_limit_rule?
    projects.count >= 5
  end

  def project_creation_config_is_blocked?
    Redis.new.get("projects_creation_blocked:user_#{self.id}").to_s == '1'
  end
end
