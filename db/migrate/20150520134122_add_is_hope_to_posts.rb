class AddIsHopeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_hope, :boolean, default: true
  end
end
