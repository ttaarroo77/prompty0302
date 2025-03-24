class UpdateTagsTable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tags, :prompt_id, true
    
    # 一度インデックスを削除
    remove_index :tags, [:prompt_id, :name], if_exists: true
    remove_index :tags, :name, if_exists: true
    
    # インデックスを再作成
    add_index :tags, [:prompt_id, :name], unique: true, where: "prompt_id IS NOT NULL"
    add_index :tags, :name, unique: true, where: "prompt_id IS NULL"
  end
end
