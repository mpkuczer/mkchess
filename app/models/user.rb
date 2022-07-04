class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :games, -> (user) { unscope(:where).where("(white_id = :id AND white_type = :type) OR (black_id = :id AND black_type = :type))",
                                                       id: user.id, type: "User") }
  has_many :challenges

  has_many :challenger_relationships, foreign_key: :challengee_id, class_name: "Challenge"
  has_many :challengers, through: :challenger_relationships, source: :challenger
  has_many :challengee_relationships, foreign_key: :challenger_id, class_name: "Challenge"
  has_many :challengees, through: :challengee_relationships, source: :challengee
end
