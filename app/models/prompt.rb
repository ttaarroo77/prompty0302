class Prompt < ApplicationRecord
  belongs_to :user
  has_many :prompt_tags, dependent: :destroy
  has_many :tags, through: :prompt_tags

  validates :title, presence: true, length: { maximum: 15 }
  validates :content, presence: true
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :url, length: { maximum: 255 }, allow_blank: true
end
