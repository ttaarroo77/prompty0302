class Tag < ApplicationRecord
  belongs_to :prompt, optional: true
  
  validates :name, presence: { message: 'を入力してください' }
  validates :name, uniqueness: { scope: :prompt_id, message: 'はすでに追加されています' }, if: -> { prompt_id.present? }
  validates :name, uniqueness: { message: 'はすでに存在します' }, if: -> { prompt_id.nil? }
  
  # タグ名を保存前に整形する
  before_validation :normalize_name
  
  private
  
  def normalize_name
    # タグ名の前後の空白を削除
    self.name = name.strip if name.present?
  end
end
