class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :user_id
      t.text :country
      t.text :capital

      t.timestamps
    end
  end
end
