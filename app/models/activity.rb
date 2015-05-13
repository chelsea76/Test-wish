class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, class: Post::Base
  belongs_to :item, polymorphic: true
end
