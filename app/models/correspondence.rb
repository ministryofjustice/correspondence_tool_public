class Correspondence < ActiveRecord::Base
# i18n-tasks-use t('activerecord.errors.models.correspondence.attributes.topic.blank')

  validates_presence_of :name,
                        :email,
                        :email_confirmation,
                        :category,
                        :topic,
                        :message

  validates :email, confirmation: { case_sensitive: false }

  validates_format_of :email, with: /\A.*@.*\z/,
    if: Proc.new { email.present? }

  validates_inclusion_of :category,
    in: Settings.correspondence_categories,
    if: Proc.new { category.present? }
  validates :topic,
    length: { maximum: Settings.correspondence_topic_max_length }

  jsonb_accessor :content,
    name: :string,
    email: :string,
    category: :string,
    topic: :string,
    message: :text
end
