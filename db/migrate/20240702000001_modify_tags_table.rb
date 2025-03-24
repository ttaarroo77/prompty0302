class ModifyTagsTable < ActiveRecord::Migration[7.1]
  def change
    # 既存のカラムを確認
    if column_exists?(:tags, :prompt_id)
      # tags テーブルに user_id カラムを追加 (もし存在しなければ)
      add_column :tags, :user_id, :bigint, null: true unless column_exists?(:tags, :user_id)
      
      # インデックスを追加
      add_index :tags, :user_id unless index_exists?(:tags, :user_id)
    end
  end
end 