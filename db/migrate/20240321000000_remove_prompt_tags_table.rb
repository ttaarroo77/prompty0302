class RemovePromptTagsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :prompt_tags if table_exists?(:prompt_tags)
  end

  def down
    create_table :prompt_tags do |t|
      t.references :prompt, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end