class RemoveDescriptionFromTags < ActiveRecord::Migration[7.1]
  def change
    remove_column :tags, :description, :text
  end
end 