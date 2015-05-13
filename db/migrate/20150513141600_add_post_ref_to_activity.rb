class AddPostRefToActivity < ActiveRecord::Migration
  def change
    add_reference :activities, :post, index: true, foreign_key: true
  end
end
