class CreateAiTagSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :ai_tag_suggestions do |t|
      t.references :prompt, null: false, foreign_key: true
      t.string :name
      t.float :confidence_score
      t.boolean :applied

      t.timestamps
    end
  end
end
