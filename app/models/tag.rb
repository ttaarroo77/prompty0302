class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :taggings, dependent: :destroy
  has_many :prompts, through: :taggings
  
  validates :name, presence: true,
                  length: { maximum: 30 },
                  format: { without: /[;'"\\]|or\s+1=1/i, message: 'に無効な文字が含まれています' },
                  uniqueness: { case_sensitive: false, message: 'は既に存在します' }
  
  # タグ名を保存前に整形する
  before_validation :normalize_name
  
  private
  
  def normalize_name
    # タグ名の前後の空白を削除
    self.name = name.strip if name.present?
    # 長すぎるタグ名は切り詰める
    self.name = name[0...30] if name.present? && name.length > 30
  end
end
