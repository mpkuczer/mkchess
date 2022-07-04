class Game < ApplicationRecord
  enum status: [:unstarted, :started, :finished]
  belongs_to :white, foreign_key: :white_id, polymorphic: true
  belongs_to :black, foreign_key: :black_id, class_name: polymorphic: true
  has_many :positions
end
