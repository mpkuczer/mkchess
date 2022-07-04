class Challenge < ApplicationRecord
  enum status: [:pending, :accepted, :rejected]
  belongs_to :challenger, class_name: "User"
  belongs_to :challengee, class_name: "User"
end
