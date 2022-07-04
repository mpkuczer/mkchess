class CreateComputers < ActiveRecord::Migration[7.0]
  def change
    create_table :computers do |t|
      t.integer :strength

      t.timestamps
    end
  end
end
