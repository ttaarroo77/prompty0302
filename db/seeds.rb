# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# シンプルなプロンプトを作成
prompt = Prompt.create!(
  title: 'ココナラのプロフィールを最適化',
  url: 'https://example.com/profile-optimization',
  description: 'ココナラのプロフィールを最適化して、より多くの注目を集め、受注率を向上させるためのアドバイスをください。'
)

# プロンプトにタグを追加
%w(ココナラ プロフィール マーケティング 最適化).each do |tag_name|
  prompt.tags.create!(name: tag_name)
end

# サンプル会話を作成
prompt.conversations.create!(
  content: "ユーザー: ココナラのプロフィールを魅力的にするにはどうすればいいですか？\n\nAIアシスタント: プロフィールには以下の要素を含めると効果的です：\n1. 専門性を示す実績や資格\n2. 提供できる具体的な価値\n3. 親しみやすい人柄が伝わる写真\n4. 明確なターゲット層の提示\n5. 具体的な成果例\n\n何か特定の分野に焦点を当てたいですか？",
  status: 'completed'
)

puts "シードデータが作成されました！"
