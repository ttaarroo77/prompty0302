class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.references :prompt, null: true, foreign_key: true
      t.string :name

      t.timestamps
    end
    
    add_index :tags, [:prompt_id, :name], unique: true
    add_index :tags, :name, unique: true, where: "prompt_id IS NULL"
  end
end
