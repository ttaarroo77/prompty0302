class ChangeTagNameLength < ActiveRecord::Migration[7.1]
  def up
    # タグ名の列長を30に変更
    change_column :tags, :name, :string, limit: 30
  end

  def down
    # 元に戻す（必要に応じて列長を元の値に戻す）
    change_column :tags, :name, :string
  end
end
