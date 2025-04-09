class AddUniqueIndexToTags < ActiveRecord::Migration[7.1]
  def change
    unless index_exists?(:tags, :name)
      add_index :tags, :name, unique: true
    end
  end
end
