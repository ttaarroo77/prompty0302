class Prompt < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :tag_suggestions, class_name: '::AI::TagSuggestion', dependent: :destroy

  validates :title, presence: true, length: { maximum: 15 }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :url, length: { maximum: 255 }, allow_blank: true
end
