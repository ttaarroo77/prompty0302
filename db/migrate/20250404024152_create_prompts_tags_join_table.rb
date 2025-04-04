class CreatePromptsTagsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts_tags, id: false do |t|
      t.belongs_to :prompt
      t.belongs_to :tag
    end
    
    add_index :prompts_tags, [:prompt_id, :tag_id], unique: true
  end
end 