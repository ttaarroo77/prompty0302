namespace :tags do
  desc "タグの追加"
  task :add, [:name] => :environment do |t, args|
    name = args[:name]
    if name.blank?
      puts "エラー: タグ名を指定してください。例: rails tags:add[タグ名]"
      next
    end
    
    begin
      tag = Tag.create!(name: name, prompt_id: nil)
      puts "タグ '#{name}' を作成しました。"
    rescue ActiveRecord::RecordInvalid => e
      puts "エラー: #{e.message}"
    end
  end
  
  desc "既存タグの一覧表示"
  task :list => :environment do
    global_tags = Tag.where(prompt_id: nil).order(:name)
    prompt_tags = Tag.where.not(prompt_id: nil).order(:name)
    
    puts "グローバルタグ一覧 (#{global_tags.count}件):"
    global_tags.each_with_index do |tag, i|
      puts "#{i+1}. #{tag.name}"
    end
    
    puts "\nプロンプト固有タグ一覧 (#{prompt_tags.count}件):"
    prompt_tags.each_with_index do |tag, i|
      puts "#{i+1}. #{tag.name} (プロンプトID: #{tag.prompt_id})"
    end
  end
  
  desc "タグを手動で追加する (対話的)"
  task :interactive => :environment do
    puts "グローバルタグの追加 (終了するには空白で Enter)"
    loop do
      print "タグ名: "
      name = STDIN.gets.chomp
      break if name.blank?
      
      begin
        tag = Tag.create!(name: name, prompt_id: nil)
        puts "✓ タグ '#{name}' を作成しました。"
      rescue ActiveRecord::RecordInvalid => e
        puts "✗ エラー: #{e.message}"
      end
    end
    
    puts "\n現在のグローバルタグ数: #{Tag.where(prompt_id: nil).count}件"
  end
end 