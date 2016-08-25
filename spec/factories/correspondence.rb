FactoryGirl.define do
  factory :correspondence do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    email_confirmation { email }
    type 'freedom_of_information_request'
    topic 'prisons_and_probation'
    message { Faker::Lorem.paragraph(1) }
  end
end
