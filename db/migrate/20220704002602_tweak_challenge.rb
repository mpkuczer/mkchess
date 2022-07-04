class TweakChallenge < ActiveRecord::Migration[7.0]
  def change
    rename_column :challenges, :challengee_id, :challengeable_id
    change_column :challenges, :status, :integer, default: 0
  end
end
