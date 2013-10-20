class Item < ActiveRecord::Base
  extend FriendlyId
    friendly_id :title, use: [:slugged, :history]
      
validates :title , presence: true


  
  def should_generate_new_friendly_id?
      new_record?
    end
   
end
