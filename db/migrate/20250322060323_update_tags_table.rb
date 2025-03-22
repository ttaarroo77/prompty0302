class UpdateTagsTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :tags, :prompt_id, true
    
    # 一度インデックスを削除
    remove_index :tags, [:prompt_id, :name]
    
    # インデックスを再作成
    add_index :tags, [:prompt_id, :name], unique: true, where: "prompt_id IS NOT NULL"
    add_index :tags, :name, unique: true, where: "prompt_id IS NULL"
  end
end
