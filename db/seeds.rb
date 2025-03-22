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

# プロンプトに関連付けられたタグを作成
["プロフィール", "ビジネス", "ココナラ", "マーケティング", "自己PR"].each do |tag_name|
  prompt.tags.create!(name: tag_name)
end

# 登録件数0のタグを追加（AIによるタグ提案機能のために利用）
standalone_tags = [
  # ビジネス関連
  "起業", "副業", "フリーランス", "リモートワーク", "在宅ワーク", "アントレプレナー",
  "キャリア", "転職", "就職", "面接", "履歴書", "職務経歴書",
  "営業", "セールス", "BtoB", "BtoC", "顧客獲得", "リード獲得",
  
  # マーケティング関連
  "コンテンツマーケティング", "SEO", "MEO", "リスティング広告", "SNS広告",
  "Instagram", "Twitter", "Facebook", "LinkedIn", "YouTube", "TikTok",
  "インフルエンサー", "ソーシャルメディア", "広告戦略", "ブランディング",
  
  # ライティング関連
  "コピーライティング", "セールスライティング", "ブログ", "記事作成",
  "メルマガ", "プレスリリース", "Webライティング", "キャッチコピー",
  
  # デザイン関連
  "グラフィックデザイン", "Webデザイン", "UIデザイン", "UXデザイン",
  "ロゴデザイン", "バナーデザイン", "イラスト", "ワイヤーフレーム",
  
  # 技術関連
  "プログラミング", "WordPress", "HTML", "CSS", "JavaScript", "PHP",
  "アプリ開発", "Webアプリ", "モバイルアプリ", "データ分析", "AI活用",
  
  # その他専門分野
  "法律", "会計", "税務", "健康", "美容", "教育", "英語", "翻訳",
  "動画編集", "ナレーション", "音声", "写真撮影", "料理", "旅行"
]

# 登録件数0のタグをDBに直接登録
standalone_tags.each do |tag_name|
  Tag.create!(name: tag_name, prompt_id: nil)
end

puts "サンプルデータの作成が完了しました。"
puts "プロンプト数: #{Prompt.count}"
puts "関連付けられたタグ数: #{Tag.where.not(prompt_id: nil).count}"
puts "登録件数0のタグ数: #{Tag.where(prompt_id: nil).count}"
