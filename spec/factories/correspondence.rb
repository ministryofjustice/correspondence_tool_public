# == Schema Information
#
# Table name: correspondence
#
#  id               :integer          not null, primary key
#  content          :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  uuid             :string
#  authenticated_at :datetime
#

FactoryBot.define do
  factory :correspondence do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    category { "general_enquiries" }
    topic { (Faker::Hipster.sentence word_count: 4, supplemental: false, random_words_to_add: 2)[0..59] }
    message { Faker::Lorem.paragraph(sentence_count: 1) }
    uuid { SecureRandom.uuid }

    trait :authenticated do
      authenticated_at { 10.minutes.ago }
    end
  end
end
