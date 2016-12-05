FactoryGirl.define do
  factory :correspondence do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    email_confirmation { email }
    category 'general_enquiries'
    topic { Faker::Hipster.sentence 4, false, 2 }
    message { Faker::Lorem.paragraph(1) }
  end
end
