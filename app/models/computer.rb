class Computer < ApplicationRecord
  has_many :challenges, as: :challengeable
end
