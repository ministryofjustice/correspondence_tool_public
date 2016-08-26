FactoryGirl.define do
  factory :correspondence do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    type 'general_enquiries'
    topic 'prisons_and_probation'
    message { Faker::Lorem.paragraph(1) }
  end
end
