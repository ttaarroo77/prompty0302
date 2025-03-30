namespace :data do
  desc "Migrate existing prompts_tags data to taggings table"
  task migrate_to_taggings: :environment do
    # 既存のプロンプトとタグの関連付けを取得
    puts "Migrating existing data to taggings table..."
    
    # 既存のデータを取得
    # 注意: この部分はデータベースに直接クエリを投げる必要があるかもしれません
    # 既存のスキーマに応じて調整してください
    ActiveRecord::Base.connection.execute("SELECT prompt_id, tag_id FROM prompts_tags").each do |row|
      prompt_id = row['prompt_id']
      tag_id = row['tag_id']
      
      begin
        Tagging.create!(prompt_id: prompt_id, tag_id: tag_id)
        puts "Created tagging: Prompt ##{prompt_id} -> Tag ##{tag_id}"
      rescue ActiveRecord::RecordInvalid => e
        puts "Error creating tagging for Prompt ##{prompt_id} -> Tag ##{tag_id}: #{e.message}"
      end
    end
    
    puts "Migration completed!"
  end
end 