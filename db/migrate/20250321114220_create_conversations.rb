class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :prompt, null: false, foreign_key: true
      t.text :content
      t.string :status, default: 'completed'

      t.timestamps
    end
  end
end
