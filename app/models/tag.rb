class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :prompts, through: :taggings
  has_many :prompt_tags, dependent: :destroy
  
  validates :name, presence: true,
                  length: { maximum: 50 },
                  format: { without: /[;'"\\]|or\s+1=1/i, message: 'に無効な文字が含まれています' },
                  uniqueness: { scope: :user_id, message: 'は既に存在します' }
  validates :description, length: { maximum: 200 }
  
  # タグ名を保存前に整形する
  before_validation :normalize_name
  
  private
  
  def normalize_name
    # タグ名の前後の空白を削除
    self.name = name.strip if name.present?
  end
end
