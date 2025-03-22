class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.references :prompt, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
    
    add_index :tags, [:prompt_id, :name], unique: true
  end
end
