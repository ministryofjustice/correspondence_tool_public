FactoryGirl.define do
  factory :feedback do
    ease_of_use {  Settings.feedback_options.sample }
    completeness {  Settings.feedback_options.sample }
    comment { Faker::Lorem.paragraph(1) }
  end
end
