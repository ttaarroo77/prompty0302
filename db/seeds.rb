# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# サンプルプロンプトを作成
prompt = Prompt.create!(
  title: "ココナラのプロフィールを最適化",
  url: "https://coconala.com/profile/edit",
  description: "ココナラで自分のスキルやサービスを効果的にアピールするためのプロフィール文章を作成したい。
  
ターゲット層は、ウェブデザインやマーケティング支援を求める中小企業経営者や個人事業主。
  
自分のスキル：
- Webデザイン（UI/UX設計）
- WordPressカスタマイズ
- マーケティング戦略立案
- SEO対策

実績：
- 小売業のECサイトリニューアルで売上30%アップ
- 飲食店の予約システム導入でオペレーションコスト削減
- アパレルブランドのSNS運用代行で認知度向上

特徴：
- 24時間以内の初回レスポンス
- 週1回の進捗報告
- 納品後1ヶ月のサポート付き"
)

# サンプルタグを作成
["プロフィール", "ビジネス", "ココナラ", "マーケティング", "自己PR"].each do |tag_name|
  prompt.tags.create!(name: tag_name)
end

puts "サンプルデータの作成が完了しました。"
