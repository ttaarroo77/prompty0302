class RemoveDescriptionFromPrompts < ActiveRecord::Migration[7.1]
  def change
    remove_column :prompts, :description, :text
  end
end 