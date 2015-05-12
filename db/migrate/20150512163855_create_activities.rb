class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true, foreign_key: true
      t.references :item, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
