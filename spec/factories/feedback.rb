FactoryGirl.define do
  factory :feedback do
    rating {  Settings.service_feedback.sample }
    comment { Faker::Lorem.paragraph(1) }
  end
end
