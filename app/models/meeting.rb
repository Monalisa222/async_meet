class Meeting < ApplicationRecord
  belongs_to :organization
  belongs_to :creator, class_name: "User"

  has_many :tasks, dependent: :destroy

  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }
end
