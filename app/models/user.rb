class User < ApplicationRecord
  has_secure_password
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  has_many :created_meetings, class_name: 'Meeting', foreign_key: 'creator_id', dependent: :nullify
  has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_user_id', dependent: :nullify

  validates :email, presence: true, uniqueness: true
end
