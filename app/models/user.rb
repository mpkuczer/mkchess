class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :games, -> (user) { unscope(:where).where("(white_id = :id AND white_type = :type) OR (black_id = :id AND black_type = :type))",
                                                       id: user.id, type: "User") }
  has_many :challenges, as: :challengeable
end
