class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.text :text
      t.string :image

      t.timestamps
    end
  end
end
