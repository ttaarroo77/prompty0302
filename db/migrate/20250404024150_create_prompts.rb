class CreatePrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts do |t|
      t.string :title, null: false, limit: 15
      t.text :content
      t.text :notes
      t.string :url, limit: 255
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
