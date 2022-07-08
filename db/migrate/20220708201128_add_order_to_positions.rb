class AddOrderToPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :positions, :order, :integer
  end
end
