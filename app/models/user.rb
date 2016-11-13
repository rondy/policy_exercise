class User < ApplicationRecord
  has_many :projects

  def manager?
    role == 'manager'
  end

  def beyond_the_projects_count_limit_rule?
    projects.count >= 5
  end
end
