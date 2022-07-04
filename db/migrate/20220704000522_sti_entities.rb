class StiEntities < ActiveRecord::Migration[7.0]
  def change
    add_column :entities, :type, :string
  end
end
