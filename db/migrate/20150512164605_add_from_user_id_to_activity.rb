class AddFromUserIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :from_user_id, :integer
  end
end
