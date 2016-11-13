class User < ApplicationRecord
  has_many :projects

  def manager?
    role == 'manager'
  end
end
