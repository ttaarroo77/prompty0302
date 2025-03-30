class Prompt < ApplicationRecord
  belongs_to :user, optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_one_attached :attachment
  
  validates :title, presence: true
end
