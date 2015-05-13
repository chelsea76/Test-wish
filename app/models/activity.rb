class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :item, polymorphic: true
end
