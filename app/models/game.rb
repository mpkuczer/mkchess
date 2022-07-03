class Game < ApplicationRecord
  enum status: [:unstarted, :started, :finished]
  belongs_to :white, foreign_key: :white_id, class_name: "User"
  belongs_to :black, foreign_key: :black_id, class_name: "User"
  has_many :positions
end
