class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :taggings, dependent: :destroy
  has_many :prompts, through: :taggings
  has_many :prompt_tags, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 30 }
  validates :name, uniqueness: { scope: :user_id }
  validates :description, length: { maximum: 200 }
  
  # タグ名を保存前に整形する
  before_validation :normalize_name
  
  private
  
  def normalize_name
    # タグ名の前後の空白を削除
    self.name = name.strip if name.present?
  end
end
