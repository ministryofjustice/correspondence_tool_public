class Feedback < ActiveRecord::Base
# i18n-tasks-use t('activerecord.errors.models.feedback.attributes.completeness.inclusion')
# i18n-tasks-use t('activerecord.errors.models.feedback.attributes.ease_of_use.inclusion')
# i18n-tasks-use t('activerecord.attributes.feedback.completeness')
# i18n-tasks-use t('activerecord.attributes.feedback.ease_of_use')

  validates :ease_of_use, :completeness, inclusion: {
              in:      Settings.feedback_options
            }

  jsonb_accessor :content,
    old_rating: [:string, store_key: :rating],
    ease_of_use: :string,
    completeness: :string,
    comment: :text
end
