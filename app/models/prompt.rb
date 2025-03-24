class Prompt < ApplicationRecord
  belongs_to :user, optional: true
  has_many :tags, dependent: :destroy
  
  validates :title, presence: true
end
