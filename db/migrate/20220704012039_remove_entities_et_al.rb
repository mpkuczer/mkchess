class RemoveEntitiesEtAl < ActiveRecord::Migration[7.0]
  def change
    drop_table :entities
    rename_column :challenges, :challengeable_id, :challengee_id
    remove_column :challenges, :challengeable_type 
  end
end
