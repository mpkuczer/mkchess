class AddPrevMoveToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :previous_move, :text
  end
end
