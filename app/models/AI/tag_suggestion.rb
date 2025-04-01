module AI
  class TagSuggestion < ApplicationRecord
    belongs_to :prompt

    validates :name, presence: true
  end
end 