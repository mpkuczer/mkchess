class AddPolymorphismToChallenge < ActiveRecord::Migration[7.0]
  def change
    add_column :challenges, :challengeable_type, :string
  end
end
