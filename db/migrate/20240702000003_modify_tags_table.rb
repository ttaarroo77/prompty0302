class ModifyTagsTable < ActiveRecord::Migration[7.1]
  def change
    # まずtagsテーブルが存在するか確認し、なければ作成
    unless table_exists?(:tags)
      create_table :tags do |t|
        t.string :name
        t.timestamps
      end
      
      add_index :tags, :name, unique: true
    end

    # 既存のカラムを確認
    if column_exists?(:tags, :name)
      # tags テーブルに user_id カラムを追加 (もし存在しなければ)
      add_column :tags, :user_id, :bigint, null: true unless column_exists?(:tags, :user_id)
      add_column :tags, :prompt_id, :bigint, null: true unless column_exists?(:tags, :prompt_id)
      
      # インデックスを追加
      add_index :tags, :user_id unless index_exists?(:tags, :user_id)
      add_index :tags, :prompt_id unless index_exists?(:tags, :prompt_id)
      add_index :tags, [:prompt_id, :name], unique: true unless index_exists?(:tags, [:prompt_id, :name])
      
      # 外部キー制約を追加
      add_foreign_key :tags, :prompts unless foreign_key_exists?(:tags, :prompts)
    end
  end
end 