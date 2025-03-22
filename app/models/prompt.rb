class Prompt < ApplicationRecord
  has_many :conversations, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  validates :title, presence: true
end
