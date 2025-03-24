class AddUserIdToPrompts < ActiveRecord::Migration[7.1]
  def change
    add_reference :prompts, :user, null: true, foreign_key: true
  end
end
