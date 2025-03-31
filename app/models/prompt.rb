class Prompt < ApplicationRecord
  belongs_to :user, optional: true
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  
  validates :title, presence: true
end
