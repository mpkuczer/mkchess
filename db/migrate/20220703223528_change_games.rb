class ChangeGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :white_id, :integer
    add_column :games, :black_id, :integer
    add_column :games, :status, :integer, default: 0
  end
end
