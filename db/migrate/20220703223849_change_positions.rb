class ChangePositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :game_id, :integer
    add_column :positions, :fen, :text
  end
end
