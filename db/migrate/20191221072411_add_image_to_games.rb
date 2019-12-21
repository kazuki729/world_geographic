class AddImageToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :image1, :binary
    add_column :games, :image2, :binary
  end
end
