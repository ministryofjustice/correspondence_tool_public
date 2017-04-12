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

FactoryGirl.define do
  factory :correspondence do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    email_confirmation { email }
    category 'general_enquiries'
    topic { (Faker::Hipster.sentence 4, false, 2)[0..59] }
    message { Faker::Lorem.paragraph(1) }
    uuid { SecureRandom.uuid }

    trait :authenticated do
      authenticated_at 10.minutes.ago
    end
  end
end
