# 管理者ユーザーの作成
admin = User.where(email: "test@example.com").first_or_create do |user|
  user.name = "test@example.com"
  user.email = "test@example.com"
  user.password = "test@example.com"
  user.password_confirmation = "test@example.com"
end
puts "管理者ユーザーを作成しました: #{admin.email}"

# サンプルプロンプトの作成
Prompt.create!(
  title: "テスト用プロンプト1",
  description: "これはテスト用のプロンプトです。AIに対する指示例として使用できます。",
  user_id: admin.id
)

Prompt.create!(
  title: "レポート作成プロンプト",
  description: "以下のトピックについて、最新の研究結果を含めた500字のレポートを作成してください。トピック：人工知能の倫理的課題",
  user_id: admin.id
)

Prompt.create!(
  title: "コード生成プロンプト",
  description: "以下の仕様に基づいてRailsのコントローラを作成してください。モデル名：Product、アクション：index, show, new, create, edit, update, destroy",
  user_id: admin.id
)
