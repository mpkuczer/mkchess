class AddPolymorphismToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :white_type, :string
    add_column :games, :black_type, :string
  end
end
