FactoryBot.define do
  factory :prompt do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    notes { Faker::Lorem.paragraph }
    user
  end
end 