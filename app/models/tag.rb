class Tag < ApplicationRecord
  belongs_to :prompt
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :prompt_id }
end
