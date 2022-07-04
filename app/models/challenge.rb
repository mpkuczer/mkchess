class Challenge < ApplicationRecord
  belongs_to :challenger, class_name: "User"
  belongs_to :challengeable, polymorphic: true
end
