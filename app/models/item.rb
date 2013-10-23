class Item < ActiveRecord::Base

validates :title , presence: true  

has_attached_file :image, :styles => {:thumb => '300x200', :original => '900x650'}, :default_url => "/images/:style/missing.png",
:storage => :dropbox,
:dropbox_credentials => Rails.root.join("config/dropbox.yml")
  
  #This for FriendlyID========
  extend FriendlyId
    friendly_id :title, use: [:slugged, :history]

  def should_generate_new_friendly_id?
      new_record?
    end
 #END OF Freiendly ID=========  


end
