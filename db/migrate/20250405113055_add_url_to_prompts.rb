class AddUrlToPrompts < ActiveRecord::Migration[7.1]
  def change
    add_column :prompts, :url, :string
  end
end
