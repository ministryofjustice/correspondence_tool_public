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

class Correspondence < ActiveRecord::Base
# i18n-tasks-use t('activerecord.errors.models.correspondence.attributes.topic.blank')

  validates_presence_of :name,
                        :email,
                        :category,
                        :topic,
                        :message,
                        :uuid

  validates :email, confirmation: { case_sensitive: false }

  validates_format_of :email, with: /\A.*@.*\z/,
    if: Proc.new { email.present? }

  validates_inclusion_of :category,
    in: Settings.correspondence_categories,
    if: Proc.new { category.present? }
  validates :topic,
    length: { maximum: Settings.correspondence_topic_max_length }
  validates :message,
            length: { maximum: Settings.correspondence_message_max_length }

  validates_inclusion_of :contact_requested,
    in: %w(yes no),
    if: Proc.new { contact_requested.present? }


  jsonb_accessor :content,
    name: :string,
    email: :string,
    category: :string,
    topic: :string,
    message: :text,
    contact_requested: :string


  def topic_present?
    errors['topic'] << " can't be blank" unless topic.present?
    topic.present?
  end

  def authenticated?
    !self.authenticated_at.nil?
  end

  def authenticate!
    unless authenticated?
      self.authenticated_at = Time.now
      save!
    end
  end
end
