# AIモジュールを読み込む
require_relative '../app/models/AI/tag_suggestion'

# 既存のデータをリセット（オプション）
if ENV['RESET_DATABASE'] == 'true'
  puts "既存のデータをリセットしています..."
  AI::TagSuggestion.destroy_all
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
  user.admin = true
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

# 共有タグを作成（管理者のタグ）
shared_tags = ["生活", "料理", "マーケティング", "デザイン"]
shared_tags.each do |tag_name|
  tag = Tag.find_or_create_by!(name: tag_name, user_id: admin.id)
  puts "共有タグを作成しました: #{tag.name}"
  created_tags[admin.id][tag_name] = tag
end

# 管理者のタグを作成
tags_data.each do |tag_data|
  next if shared_tags.include?(tag_data[:name])
  tag = Tag.find_or_create_by!(name: tag_data[:name], user_id: tag_data[:user_id])
  puts "タグを作成しました: #{tag.name}"
  created_tags[admin.id][tag_data[:name]] = tag
end

# 山田太郎のタグを作成
yamada_tags_data.each do |tag_data|
  next if shared_tags.include?(tag_data[:name])
  tag = Tag.find_or_create_by!(name: tag_data[:name], user_id: tag_data[:user_id])
  puts "山田太郎のタグを作成しました: #{tag.name}"
  created_tags[user2.id][tag_data[:name]] = tag
end

# 田中花子のタグを作成
tanaka_tags_data.each do |tag_data|
  next if shared_tags.include?(tag_data[:name])
  tag = Tag.find_or_create_by!(name: tag_data[:name], user_id: tag_data[:user_id])
  puts "田中花子のタグを作成しました: #{tag.name}"
  created_tags[user3.id][tag_data[:name]] = tag
end

# プロンプトデータの作成
def create_prompt_with_tags(prompt_data, user_tags, created_tags, admin_id)
  prompt = Prompt.find_by(title: prompt_data[:title], user_id: prompt_data[:user_id])
  
  if prompt.nil?
    prompt = Prompt.create!(
      title: prompt_data[:title],
      content: prompt_data[:content],
      notes: prompt_data[:notes],
      user_id: prompt_data[:user_id]
    )
    puts "プロンプトを作成しました: #{prompt.title}"
  else
    puts "プロンプトが既に存在します: #{prompt.title}"
  end

  # タグの関連付け
  prompt_data[:tags].each do |tag_name|
    tag = nil
    if created_tags[admin_id][tag_name]
      tag = created_tags[admin_id][tag_name]
    elsif user_tags.include?(tag_name)
      tag = created_tags[prompt_data[:user_id]][tag_name]
    else
      tag = Tag.find_or_create_by!(name: tag_name, user_id: prompt_data[:user_id])
      created_tags[prompt_data[:user_id]][tag_name] = tag
    end

    unless prompt.tags.include?(tag)
      prompt.tags << tag
      puts "タグ「#{tag.name}」をプロンプト「#{prompt.title}」に紐づけました"
    end
  end

  prompt
end

# 管理者のプロンプト
admin_prompts = [
  {
    title: "テスト用プロンプト1",
    content: "これはテスト用のプロンプトです。",
    notes: "テスト用のプロンプトです。",
    user_id: admin.id,
    tags: ["プログラミング", "AI"]
  },
  {
    title: "レポート作成",
    content: "以下のフォーマットで[テーマ]に関するレポートを作成してください。\n\n## 概要\n\n## 背景\n\n## 現状分析\n\n## 課題\n\n## 解決策\n\n## まとめ",
    notes: "ビジネスレポート作成用のプロンプト",
    user_id: admin.id,
    tags: ["ビジネス", "レポート"]
  },
  {
    title: "自己PR文",
    content: "以下の項目に沿って、私の経歴と強みを活かした自己PR文を300文字程度で作成してください。\n\n【職歴】\n[職歴]\n\n【スキル】\n[スキル]\n\n【強み】\n[強み]\n\n【志望動機】\n[志望動機]",
    notes: "就職・転職活動用の自己PR文作成プロンプト",
    user_id: admin.id,
    tags: ["自己PR", "文章作成"]
  },
  {
    title: "コード解説",
    content: "以下のコードについて、初心者にもわかりやすく解説してください。各行の処理内容と全体の目的、使われている技術や概念について説明してください。\n\n```\n[コードをここに貼り付け]\n```",
    notes: "プログラミング学習用",
    user_id: admin.id,
    tags: ["プログラミング", "教育"]
  },
  {
    title: "マーケ戦略立案",
    content: "以下の情報をもとに、効果的なマーケティング戦略を立案してください。\n\n【製品/サービス】\n[製品/サービスの説明]\n\n【ターゲット】\n[ターゲット層]\n\n【競合状況】\n[競合状況]\n\n【予算】\n[予算]\n\n【目標】\n[目標]",
    notes: "マーケティング戦略立案用",
    user_id: admin.id,
    tags: ["マーケティング", "ビジネス"]
  }
]

# 山田太郎のプロンプト
yamada_prompts = [
  {
    title: "週末の簡単レシピ",
    content: "週末に作れる簡単なレシピのプロンプトです。",
    notes: "週末に作れる簡単なレシピのプロンプトです。",
    user_id: user2.id,
    tags: ["料理", "生活"]
  }
]

# 田中花子のプロンプト
tanaka_prompts = [
  {
    title: "写真撮影のコツ",
    content: "料理写真の撮影テクニックについてのプロンプトです。",
    notes: "料理写真の撮影テクニックについてのプロンプトです。",
    user_id: user3.id,
    tags: ["写真", "料理"]
  },
  {
    title: "SNS投稿文の例",
    content: "SNSの投稿文を作成するためのプロンプトです。",
    notes: "SNSの投稿文を作成するためのプロンプトです。",
    user_id: user3.id,
    tags: ["SNS", "マーケティング"]
  }
]

# プロンプトの作成
admin_prompts.each do |prompt_data|
  prompt = create_prompt_with_tags(prompt_data, [], created_tags, admin.id)
  
  # AIタグ提案の作成
  ai_tags = [
    { name: "自己PR", confidence_score: 0.9 },
    { name: "プロフィール", confidence_score: 0.8 },
    { name: "ビジネス", confidence_score: 0.7 }
  ]

  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all
  
  ai_tags.each do |tag_data|
    AI::TagSuggestion.create!(
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      applied: false
    )
    puts "AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

# 山田太郎のプロンプト作成
yamada_prompts.each do |prompt_data|
  prompt = create_prompt_with_tags(prompt_data, yamada_tags_data.map { |t| t[:name] }, created_tags, admin.id)
  
  # AIタグ提案
  yamada_ai_tags = [
    { name: "レシピ", confidence_score: 0.9 },
    { name: "健康管理", confidence_score: 0.8 },
    { name: "ライフスタイル", confidence_score: 0.7 }
  ]

  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all
  
  yamada_ai_tags.each do |tag_data|
    AI::TagSuggestion.create!(
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      applied: false
    )
    puts "山田太郎のプロンプト用AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

# 田中花子のプロンプト作成
tanaka_prompts.each do |prompt_data|
  prompt = create_prompt_with_tags(prompt_data, tanaka_tags_data.map { |t| t[:name] }, created_tags, admin.id)
  
  # AIタグ提案
  tanaka_ai_tags = [
    { name: "クリエイティブ", confidence_score: 0.9 },
    { name: "アート", confidence_score: 0.8 },
    { name: "インスピレーション", confidence_score: 0.7 }
  ]

  AI::TagSuggestion.where(prompt_id: prompt.id).delete_all
  
  tanaka_ai_tags.each do |tag_data|
    AI::TagSuggestion.create!(
      prompt_id: prompt.id,
      name: tag_data[:name],
      confidence_score: tag_data[:confidence_score],
      applied: false
    )
    puts "田中花子のプロンプト用AIタグ提案を作成しました: #{tag_data[:name]} (#{prompt.title})"
  end
end

puts "シードの作成が完了しました！"
