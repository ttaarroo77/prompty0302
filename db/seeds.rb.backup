# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ユーザーデータの作成
puts "ユーザーデータを作成しています..."

# 管理者ユーザーの作成
admin = User.where(email: 'test@example.com').first_or_create do |user|
  user.name = 'test@example.com'
  user.email = 'test@example.com'
  user.password = 'test@example.com'
  user.password_confirmation = 'test@example.com'
end
puts "管理者ユーザーを作成しました: #{admin.email}"

# 一般ユーザーの作成
normal_user = User.where(email: 'tarou.nakazawa@gmail.com').first_or_create do |user|
  user.name = 'tarou.nakazawa'
  user.email = 'tarou.nakazawa@gmail.com'
  user.password = 'qwer1234'
  user.password_confirmation = 'qwer1234'
end
puts "一般ユーザーを作成しました: #{normal_user.email}"

# サンプルプロンプトを作成 (管理者ユーザー用)
admin_prompts = [
  {
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
- 納品後1ヶ月のサポート付き",
    tags: ["プロフィール", "ビジネス", "ココナラ", "マーケティング", "自己PR"]
  },
  {
    title: "社会性偽装装置",
    url: "https://chatgpt.com/g/g-67c0b9d36bedc8191b066...",
    description: "### 🌸 「社会性偽装装置」の用途：全体概要と使い方 ###

この社会性偽装装置は、生きづらさを感じるあなたをサポートする特殊プロンプトです。現代社会でのコミュニケーションに悩む際に活用できます。

【使用例】
- 会議やオンライン飲み会での発言内容の考案
- 上司/先輩/同僚とのやり取りで何を言うべきか悩んだとき
- SNSでの適切な反応や投稿内容の作成
- メールや連絡事項の書き方のアドバイス
- 恋愛や友人関係での会話の進め方

【指示方法】
会話の状況と、あなたが何に困っているかを具体的に説明してください。",
    tags: ["test", "AI", "ChatGPT", "社会性"]
  }
]

admin_prompts.each do |prompt_data|
  prompt = Prompt.create!(
    title: prompt_data[:title],
    url: prompt_data[:url],
    description: prompt_data[:description],
    user_id: admin.id
  )
  
  prompt_data[:tags].each do |tag_name|
    prompt.tags.create!(name: tag_name)
  end
  
  puts "管理者用プロンプトを作成しました: #{prompt.title}"
end

# サンプルプロンプトを作成 (一般ユーザー用)
normal_user_prompts = [
  {
    title: "ビジネスメールの文章校正・改善",
    url: "https://example.com/business-email",
    description: "ビジネスメールの文章を校正し、より効果的で専門的な表現に改善してください。

【原文】
以下のメールを添削してください。
{ここにメールの原文を貼り付け}

【校正ポイント】
1. 敬語や丁寧語の適切な使用
2. ビジネス文書として相応しい表現への修正
3. 文章の構成や流れの改善
4. 簡潔で明瞭な表現への修正
5. 誤字脱字の修正

【レベル設定】
- フォーマル度: 高め（取引先や上司向け）
- 簡潔さ: 要点を押さえつつ丁寧に
- 専門性: 一般的なビジネス文書レベル",
    tags: ["ビジネス", "メール", "文章校正", "ビジネス文書", "コミュニケーション"]
  },
  {
    title: "商品紹介文の作成",
    url: "https://coconala.com/services/writing",
    description: "ECサイトやウェブショップ向けの魅力的な商品紹介文を作成します。

【必要情報】
- 商品名: {商品名}
- 商品カテゴリ: {カテゴリ}
- 主な特徴: {箇条書きで3-5つ}
- ターゲット顧客: {ターゲット層の説明}
- 価格帯: {価格}
- 差別化ポイント: {競合製品との違い}

【出力形式】
1. キャッチコピー（15-20文字程度）
2. リード文（50-60文字程度）
3. 商品説明本文（400-500文字程度）
  - 特徴の詳細説明
  - 使用シーン
  - 品質/素材の説明
4. まとめ/購入を促す文章（50-60文字程度）
5. 補足情報（サイズ、カラーバリエーションなど）",
    tags: ["コピーライティング", "ECサイト", "商品紹介", "マーケティング", "セールスライティング"]
  },
  {
    title: "ブログ記事構成の作成",
    url: "https://coconala.com/services/blog",
    description: "SEOを意識したブログ記事の詳細な構成を作成します。

【キーワード】
{メインキーワード}

【サブキーワード】
{サブキーワード1, サブキーワード2, サブキーワード3...}

【記事のテーマ/目的】
{記事のテーマと目的の説明}

【ターゲット読者】
{ターゲット読者の詳細}

【希望する記事の長さ】
{文字数目安}

【出力内容】
1. SEO最適化されたタイトル案（3パターン）
2. メタディスクリプション案
3. 導入文の構成ポイント
4. 見出し構成（H2, H3まで）
5. 各見出しで言及すべき内容
6. 記事全体で使用すべきキーワードとその配置
7. 読者の行動を促すコールトゥアクション案
8. 参考にすべき情報源やデータ",
    tags: ["SEO", "ブログ", "コンテンツマーケティング", "記事構成", "ライティング"]
  }
]

normal_user_prompts.each do |prompt_data|
  prompt = Prompt.create!(
    title: prompt_data[:title],
    url: prompt_data[:url],
    description: prompt_data[:description],
    user_id: normal_user.id
  )
  
  prompt_data[:tags].each do |tag_name|
    prompt.tags.create!(name: tag_name)
  end
  
  puts "一般ユーザー用プロンプトを作成しました: #{prompt.title}"
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
  Tag.where(name: tag_name, prompt_id: nil).first_or_create
end

puts "===== シードデータ作成完了 ====="
puts "ユーザー数: #{User.count}"
puts "プロンプト数: #{Prompt.count}"
puts "関連付けられたタグ数: #{Tag.where.not(prompt_id: nil).count}"
puts "登録件数0のタグ数: #{Tag.where(prompt_id: nil).count}"
