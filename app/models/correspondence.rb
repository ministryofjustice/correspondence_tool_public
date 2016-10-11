class Correspondence < ActiveRecord::Base

  validates_presence_of :topic,
                        :message,
                        :name,
                        :email,
                        :email_confirmation,
                        :category

  validates :email, confirmation: { case_sensitive: false }

  validates_format_of :email, with: /\A.*@.*\z/,
    if: Proc.new { email.present? }

  validates_inclusion_of :category,
    in: Settings.correspondence_categories,
    if: Proc.new { category.present? }
  validates_inclusion_of :topic,
    in: Settings.correspondence_topics,
    if: Proc.new { topic.present? }
end
