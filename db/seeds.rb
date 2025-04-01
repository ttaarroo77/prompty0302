# AIモジュールを読み込む
# require_relative '../app/models/ai/tag_suggestion'
require_relative '../app/models/AI/tag_suggestion'


# 既存のデータをリセット（オプション）
if ENV['RESET_DATABASE'] == 'true'
  puts "既存のデータをリセットしています..."
  AI::TagSuggestion.destroy_all # ここ、参照の問題・・大丈夫？？
  Prompt.destroy_all
  Tag.destroy_all
  User.destroy_all
end

# 管理者ユーザーの作成
admin = User.where(email: "test@example.com").first_or_create do |user|
  user.name = "test@example.com"
  user.email = "test@example.com"
  user.password = "test@example.com"
  user.password_confirmation = "test@example.com"
end
puts "管理者ユーザーを作成しました: #{admin.email}"

# 別のユーザーを作成
user2 = User.where(email: "yamada@example.com").first_or_create do |user|
  user.name = "山田太郎"
  user.email = "yamada@example.com"
  user.password = "password123"
  user.password_confirmation = "password123"
end
puts "別のユーザーを作成しました: #{user2.email}"

user3 = User.where(email: "tanaka@example.com").first_or_create do |user|
  user.name = "田中花子"
  user.email = "tanaka@example.com"
  user.password = "password456"
  user.password_confirmation = "password456"
end
puts "別のユーザーを作成しました: #{user3.email}"

# サンプルタグの作成
tags_data = [
  { name: "プログラミング", user_id: admin.id },
  { name: "ビジネス", user_id: admin.id },
  { name: "マーケティング", user_id: admin.id },
  { name: "AI", user_id: admin.id },
  { name: "自己PR", user_id: admin.id },
  { name: "レポート", user_id: admin.id },
  { name: "デザイン", user_id: admin.id },
  { name: "教育", user_id: admin.id },
  { name: "研究", user_id: admin.id },
  { name: "文章作成", user_id: admin.id }
]

# 山田太郎用のタグ
yamada_tags_data = [
  { name: "料理", user_id: user2.id },
  { name: "旅行", user_id: user2.id },
  { name: "健康", user_id: user2.id },
  { name: "エンタメ", user_id: user2.id },
  { name: "ブログ", user_id: user2.id },
  { name: "小説", user_id: user2.id }
]

# 田中花子用のタグ
tanaka_tags_data = [
  { name: "イラスト", user_id: user3.id },
  { name: "写真", user_id: user3.id },
  { name: "音楽", user_id: user3.id },
  { name: "SNS", user_id: user3.id },
  { name: "生活", user_id: user3.id }
]

# タグをユーザーごとに管理するハッシュ
created_tags = {
  admin.id => {},
  user2.id => {},
  user3.id => {}
}

# 管理者のタグを作成
tags_data.each do |tag_data|
  tag = Tag.find_or_initialize_by(name: tag_data[:name], user_id: tag_data[:user_id])
  if tag.new_record?
    tag.save!
    puts "タグを作成しました: #{tag.name}"
  end
  created_tags[admin.id][tag_data[:name]] = tag
end

# 山田太郎のタグを作成
yamada_tags_data.each do |tag_data|
  tag = Tag.find_or_initialize_by(name: tag_data[:name], user_id: tag_data[:user_id])
  if tag.new_record?
    tag.save!
    puts "山田太郎のタグを作成しました: #{tag.name}"
  end
  created_tags[user2.id][tag_data[:name]] = tag
end

# 田中花子のタグを作成
tanaka_tags_data.each do |tag_data|
  tag = Tag.find_or_initialize_by(name: tag_data[:name], user_id: tag_data[:user_id])
  if tag.new_record?
    tag.save!
    puts "田中花子のタグを作成しました: #{tag.name}"
  end
  created_tags[user3.id][tag_data[:name]] = tag
end

# サンプルプロンプトの作成
prompts_data = [
  {
    title: "テスト用プロンプト1",
    description: "これはテスト用のプロンプトです。AIに対する指示例として使用できます。",
    user_id: admin.id,
    url: "https://test-prompt.example.com",
    tags: ["AI", "テスト"]
  },
  {
    title: "レポート作成プロンプト",
    description: "以下のトピックについて、最新の研究結果を含めた500字のレポートを作成してください。トピック：人工知能の倫理的課題",
    user_id: admin.id,
    url: "https://report-writing.example.com/ai-ethics",
    tags: ["AI", "レポート", "研究"]
  },
  {
    title: "コード生成プロンプト",
    description: "以下の仕様に基づいてRailsのコントローラを作成してください。モデル名：Product、アクション：index, show, new, create, edit, update, destroy",
    user_id: admin.id,
    url: "https://code-generator.example.com/rails",
    tags: ["プログラミング", "AI"]
  },
  {
    title: "自己PR文の作成",
    description: "私は情報技術分野で5年の経験があり、特にRuby on Railsとフロントエンド開発に強みがあります。チーム開発やアジャイル手法にも慣れています。これらの経験と技術を生かして、御社のプロダクト開発にどのように貢献できるかを、300字程度でまとめてください。",
    user_id: admin.id,
    url: "https://example.com/portfolio",
    tags: ["自己PR", "ビジネス"]
  },
  {
    title: "マーケティング戦略提案",
    description: "新規サービスのマーケティング戦略を考えています。ターゲットは20代から30代の働く女性で、時短料理キットのサブスクリプションサービスです。SNSを活用した効果的なマーケティング施策を5つ提案してください。",
    user_id: admin.id,
    url: "https://marketing-strategy.example.com/subscription",
    tags: ["マーケティング", "ビジネス"]
  },
  {
    title: "ウェブデザインのアイデア",
    description: "ミニマルで洗練されたポートフォリオサイトのデザインを考えています。白を基調とし、アクセントカラーとして青と緑を使用する場合のレイアウトと色使いについてアドバイスをください。",
    user_id: admin.id,
    url: "https://web-design.example.com/portfolio",
    tags: ["デザイン", "ポートフォリオ"]
  },
  {
    title: "数学の問題解説プロンプト",
    description: "高校生向けに、二次方程式の解の公式について、わかりやすく説明してください。導出過程も含め、具体例を挙げて説明してください。",
    user_id: admin.id,
    url: "https://math-education.example.com/quadratic",
    tags: ["教育", "数学"]
  },
  {
    title: "研究論文の要約",
    description: "以下の論文の要約を200字程度で作成してください。キーポイントと主な発見を中心にまとめてください。[論文タイトル: AIを活用した教育手法の最新動向]",
    user_id: admin.id,
    url: "https://research-summary.example.com/ai-education",
    tags: ["研究", "AI", "教育"]
  },
  {
    title: "英語学習用会話シナリオ",
    description: "カフェでの注文を題材にした英会話のシナリオを作成してください。初級者向けで、基本的な挨拶、注文、お礼などを含めてください。各フレーズには日本語訳も付けてください。",
    user_id: admin.id,
    url: "https://english-learning.example.com/cafe-conversation",
    tags: ["教育", "英語", "会話"]
  },
  {
    title: "プレゼンテーション資料作成",
    description: "「デジタルトランスフォーメーションの課題と解決策」というテーマでプレゼンテーション資料を作成しています。10枚のスライドの構成と、各スライドの要点をまとめてください。",
    user_id: admin.id,
    url: "https://presentation.example.com/digital-transformation",
    tags: ["ビジネス", "プレゼンテーション"]
  }
]

# 山田太郎のプロンプト
yamada_prompts_data = [
  {
    title: "週末の簡単レシピ",
    description: "20分以内で作れる、料理初心者向けの週末夕食レシピを5つ提案してください。和食中心で、食材は一般的なスーパーで手に入るものを使用してください。",
    user_id: user2.id,
    url: "https://recipe-example.com/weekend",
    tags: ["料理", "健康", "家庭料理"]
  },
  {
    title: "国内旅行計画",
    description: "京都への2泊3日の旅行プランを立ててください。主な観光スポット、おすすめの食事処、宿泊施設の提案を含めてください。公共交通機関を使った移動を前提としています。",
    user_id: user2.id,
    url: "https://kyoto-travel.com",
    tags: ["旅行", "エンタメ"]
  },
  {
    title: "ブログ投稿アイデア",
    description: "健康とフィットネスに関するブログを運営しています。次の1ヶ月間で投稿する記事のアイデアを10個提案してください。各アイデアには簡単な概要も含めてください。",
    user_id: user2.id,
    url: "https://blog-ideas.com/fitness",
    tags: ["ブログ", "健康", "文章作成"]
  },
  {
    title: "短編小説のプロット",
    description: "現代を舞台にした3000字程度の短編ミステリー小説のプロットを考えてください。主人公は30代の女性会社員で、通勤途中に不思議な出来事に遭遇するという設定です。",
    user_id: user2.id,
    url: "https://short-story.example.com/mystery",
    tags: ["小説", "エンタメ"]
  }
]

# 田中花子のプロンプト
tanaka_prompts_data = [
  {
    title: "イラスト作成のアイデア",
    description: "季節をテーマにしたイラスト集を作成しています。夏をテーマにした5つのイラストアイデアを提案してください。それぞれ簡単な構図の説明を含めてください。",
    user_id: user3.id,
    url: "https://illustration-ideas.com/seasonal",
    tags: ["イラスト", "デザイン"]
  },
  {
    title: "写真撮影のテクニック",
    description: "スマートフォンでプロフェッショナルな料理写真を撮影するためのテクニックを教えてください。照明、構図、角度などの観点から詳しく説明してください。",
    user_id: user3.id,
    url: "https://photo-tips.example.com/food",
    tags: ["写真", "料理"]
  },
  {
    title: "SNS投稿文の例",
    description: "新しく始めた手作りアクセサリーショップのInstagramアカウント用の投稿文を5つ作成してください。商品の魅力を伝え、フォロワーの関心を引くような内容にしてください。ハッシュタグも含めてください。",
    user_id: user3.id,
    url: "https://instagram.com/handmade_accessories",
    tags: ["SNS", "マーケティング"]
  },
  {
    title: "音楽プレイリスト作成",
    description: "集中して作業するための3時間のプレイリストを提案してください。ジャンルは問いませんが、歌詞のないインストゥルメンタル曲を中心にしてください。各曲の簡単な説明も含めてください。",
    user_id: user3.id,
    url: "https://music-playlist.example.com/focus",
    tags: ["音楽", "作業効率"]
  },
  {
    title: "季節のインテリアアイデア",
    description: "秋を感じる部屋のインテリアアイデアを提案してください。少ない予算で実現できる、色使いや小物の配置などのアイデアを5つ以上挙げてください。",
    user_id: user3.id,
    url: "https://interior-design.example.com/autumn",
    tags: ["生活", "デザイン"]
  }
]

# 管理者のプロンプトを作成
prompts_data.each do |prompt_data|
  # 既存のプロンプトを探すか、新しく作成
  prompt = Prompt.find_by(title: prompt_data[:title], user_id: prompt_data[:user_id])
  
  if prompt.nil?
    # 新規作成の場合
    prompt = Prompt.create!(
      title: prompt_data[:title],
      description: prompt_data[:description],
      url: prompt_data[:url],
      user_id: prompt_data[:user_id]
    )
    puts "プロンプトを作成しました: #{prompt.title}"
  else
    puts "プロンプトが既に存在します: #{prompt.title}"
  end
  
  # タグの関連付け
  prompt_data[:tags].each do |tag_name|
    # タグが存在するか確認
    tag = nil
    if created_tags[admin.id][tag_name]
      tag = created_tags[admin.id][tag_name]
    else
      # タグが存在しなければ作成
      tag = Tag.find_or_initialize_by(name: tag_name, user_id: admin.id)
      if tag.new_record?
        tag.save!
        puts "管理者用のタグを作成しました: #{tag.name}"
        created_tags[admin.id][tag_name] = tag
      end
    end
    
    # タグとプロンプトを関連付け（既に関連付けられていなければ）
    unless prompt.tags.include?(tag)
      prompt.tags << tag
      puts "タグ「#{tag.name}」をプロンプト「#{prompt.title}」に紐づけました"
    end
  end
  
  # AIタグ提案の作成
  ai_tags = [
    { name: "自己PR", confidence_score: 0.9 },
    { name: "プロフィール", confidence_score: 0.8 },
    { name: "ビジネス", confidence_score: 0.7 },
    { name: "マーケティング", confidence_score: 0.6 },
    { name: "ポートフォリオ", confidence_score: 0.5 },
    { name: "実績", confidence_score: 0.4 },
    { name: "デザイン", confidence_score: 0.3 }
  ]
  
  # タグ提案をクリアして新しいものを作成
  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all # ここ、参照の問題・・大丈夫？？
  
  ai_tags.sample(3).each do |tag_data|
    AI::TagSuggestion.create!( # ここ、参照の問題・・大丈夫？？
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      source: "AI",
      applied: false
    )
    puts "AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

# 山田太郎のプロンプトを作成
yamada_prompts_data.each do |prompt_data|
  prompt = Prompt.find_by(title: prompt_data[:title], user_id: prompt_data[:user_id])
  
  if prompt.nil?
    prompt = Prompt.create!(
      title: prompt_data[:title],
      description: prompt_data[:description],
      url: prompt_data[:url],
      user_id: prompt_data[:user_id]
    )
    puts "山田太郎のプロンプトを作成しました: #{prompt.title}"
  else
    puts "山田太郎のプロンプトが既に存在します: #{prompt.title}"
  end
  
  prompt_data[:tags].each do |tag_name|
    # タグが存在するか確認
    tag = nil
    
    # ユーザー固有のタグか共有タグかを判断
    if ["料理", "旅行", "健康", "エンタメ", "ブログ", "小説"].include?(tag_name)
      # 山田太郎のタグ
      if created_tags[user2.id][tag_name]
        tag = created_tags[user2.id][tag_name]
      else
        tag = Tag.find_or_initialize_by(name: tag_name, user_id: user2.id)
        if tag.new_record?
          tag.save!
          puts "山田太郎用のタグを作成しました: #{tag.name}"
          created_tags[user2.id][tag_name] = tag
        end
      end
    else
      # 共有タグ（管理者のタグ）
      if created_tags[admin.id][tag_name]
        tag = created_tags[admin.id][tag_name]
      else
        tag = Tag.find_or_initialize_by(name: tag_name, user_id: admin.id)
        if tag.new_record?
          tag.save!
          puts "管理者用のタグを作成しました: #{tag.name}"
          created_tags[admin.id][tag_name] = tag
        end
      end
    end
    
    unless prompt.tags.include?(tag)
      prompt.tags << tag
      puts "タグ「#{tag.name}」を山田太郎のプロンプト「#{prompt.title}」に紐づけました"
    end
  end
  
  # AIタグ提案
  yamada_ai_tags = [
    { name: "レシピ", confidence_score: 0.9 },
    { name: "旅行プラン", confidence_score: 0.85 },
    { name: "健康管理", confidence_score: 0.8 },
    { name: "フィットネス", confidence_score: 0.75 },
    { name: "ライフスタイル", confidence_score: 0.7 },
    { name: "創作", confidence_score: 0.65 }
  ]
  
  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all # ここ、参照の問題・・大丈夫？？
  
  yamada_ai_tags.sample(3).each do |tag_data|
    AI::TagSuggestion.create!( # ここ、参照の問題・・大丈夫？？
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      source: "AI",
      applied: false
    )
    puts "山田太郎のプロンプト用AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

# 田中花子のプロンプトを作成
tanaka_prompts_data.each do |prompt_data|
  prompt = Prompt.find_by(title: prompt_data[:title], user_id: prompt_data[:user_id])
  
  if prompt.nil?
    prompt = Prompt.create!(
      title: prompt_data[:title],
      description: prompt_data[:description],
      url: prompt_data[:url],
      user_id: prompt_data[:user_id]
    )
    puts "田中花子のプロンプトを作成しました: #{prompt.title}"
  else
    puts "田中花子のプロンプトが既に存在します: #{prompt.title}"
  end
  
  prompt_data[:tags].each do |tag_name|
    # タグが存在するか確認
    tag = nil
    
    # ユーザー固有のタグか共有タグかを判断
    if ["イラスト", "写真", "音楽", "SNS", "生活"].include?(tag_name)
      # 田中花子のタグ
      if created_tags[user3.id][tag_name]
        tag = created_tags[user3.id][tag_name]
      else
        tag = Tag.find_or_initialize_by(name: tag_name, user_id: user3.id)
        if tag.new_record?
          tag.save!
          puts "田中花子用のタグを作成しました: #{tag.name}"
          created_tags[user3.id][tag_name] = tag
        end
      end
    elsif ["料理", "旅行", "健康", "エンタメ", "ブログ", "小説"].include?(tag_name)
      # 山田太郎のタグ
      if created_tags[user2.id][tag_name]
        tag = created_tags[user2.id][tag_name]
      else
        tag = Tag.find_or_initialize_by(name: tag_name, user_id: user2.id)
        if tag.new_record?
          tag.save!
          puts "山田太郎用のタグを作成しました: #{tag.name}"
          created_tags[user2.id][tag_name] = tag
        end
      end
    else
      # 共有タグ（管理者のタグ）
      if created_tags[admin.id][tag_name]
        tag = created_tags[admin.id][tag_name]
      else
        tag = Tag.find_or_initialize_by(name: tag_name, user_id: admin.id)
        if tag.new_record?
          tag.save!
          puts "管理者用のタグを作成しました: #{tag.name}"
          created_tags[admin.id][tag_name] = tag
        end
      end
    end
    
    unless prompt.tags.include?(tag)
      prompt.tags << tag
      puts "タグ「#{tag.name}」を田中花子のプロンプト「#{prompt.title}」に紐づけました"
    end
  end
  
  # AIタグ提案
  tanaka_ai_tags = [
    { name: "クリエイティブ", confidence_score: 0.95 },
    { name: "アート", confidence_score: 0.9 },
    { name: "写真撮影", confidence_score: 0.85 },
    { name: "インスピレーション", confidence_score: 0.8 },
    { name: "デジタル", confidence_score: 0.75 },
    { name: "ソーシャルメディア", confidence_score: 0.7 },
    { name: "インテリア", confidence_score: 0.65 }
  ]
  
  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all
  
  tanaka_ai_tags.sample(3).each do |tag_data|
    AI::TagSuggestion.create!( # ここ、参照の問題・・大丈夫？？
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      source: "AI",
      applied: false
    )
    puts "田中花子のプロンプト用AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

puts "シードの作成が完了しました！"
