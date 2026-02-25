class Task < ApplicationRecord
  belongs_to :meeting
  belongs_to :organization
  belongs_to :assigned_user, class_name: "User"

  enum status: { pending: 0, in_progress: 1, done: 2 }
  enum priority: { low: 0, medium: 1, high: 2 }
end
