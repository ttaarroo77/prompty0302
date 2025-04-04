class ModifyTagsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false, limit: 21
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :tags, :name, unique: true
  end
end