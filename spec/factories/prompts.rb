FactoryBot.define do
  factory :prompt do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    content { Faker::Lorem.paragraphs(number: 3).join("\n") }
    notes { Faker::Lorem.paragraph }
    user
  end
end 