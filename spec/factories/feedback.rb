# == Schema Information
#
# Table name: feedback
#
#  id         :integer          not null, primary key
#  content    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :feedback do
    ease_of_use {  Settings.feedback_options.sample }
    completeness {  Settings.feedback_options.sample }
    comment { Faker::Lorem.paragraph(sentence_count: 1) }
  end
end
