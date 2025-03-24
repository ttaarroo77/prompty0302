class ModifyTagsTable < ActiveRecord::Migration[7.1]
  def change
    # まずtagsテーブルが存在するか確認し、なければ作成
    unless table_exists?(:tags)
      create_table :tags do |t|
        t.references :prompt, null: true, foreign_key: true
        t.string :name
        t.timestamps
      end
      
      add_index :tags, [:prompt_id, :name], unique: true
      add_index :tags, :name, unique: true, where: "prompt_id IS NULL"
    end

    # 既存のカラムを確認
    if column_exists?(:tags, :prompt_id)
      # tags テーブルに user_id カラムを追加 (もし存在しなければ)
      add_column :tags, :user_id, :bigint, null: true unless column_exists?(:tags, :user_id)
      
      # インデックスを追加
      add_index :tags, :user_id unless index_exists?(:tags, :user_id)
    end
  end
end 