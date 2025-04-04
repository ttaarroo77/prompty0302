class AddContentAndNotesToPrompts < ActiveRecord::Migration[7.1]
  def change
    add_column :prompts, :content, :text
    add_column :prompts, :notes, :text
  end
end
