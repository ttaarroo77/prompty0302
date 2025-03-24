class Tag < ApplicationRecord
  has_and_belongs_to_many :prompts
  belongs_to :user, optional: true
  
  validates :name, presence: true
end
