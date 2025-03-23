class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.string :title
      t.string :url
      t.text :description

      t.timestamps
    end
  end
end
