class Tag < ApplicationRecord
  belongs_to :prompt, optional: true
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :prompt_id }, if: -> { prompt_id.present? }
  validates :name, uniqueness: true, if: -> { prompt_id.nil? }
end
