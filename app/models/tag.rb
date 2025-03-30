class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :taggings, dependent: :destroy
  has_many :prompts, through: :taggings
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id }
  
  # タグ名を保存前に整形する
  before_validation :normalize_name
  
  private
  
  def normalize_name
    # タグ名の前後の空白を削除
    self.name = name.strip if name.present?
  end
end
