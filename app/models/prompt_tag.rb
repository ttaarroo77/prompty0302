class PromptTag < ApplicationRecord
  belongs_to :prompt
  belongs_to :tag
end 