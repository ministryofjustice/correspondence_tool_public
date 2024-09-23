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

class Correspondence < ApplicationRecord
  attr_readonly :uuid

  validates :category,
            :topic, presence: true

  validates :name, presence: { message: "Full name can't be blank" }
  validates :email, presence: { message: "Email can't be blank" }
  validates :message, presence: { message: "Your message can't be blank" }

  validates :email, confirmation: { case_sensitive: false }

  validates :email, format: { with: /\A.*@.*\z/,
                              message: "Email is invalid",
                              if: proc { email.present? } }

  validates :category,
            inclusion: { in: Settings.correspondence_categories,
                         if: proc { category.present? } }
  validates :topic,
            length: { maximum: Settings.correspondence_topic_max_length }
  validates :message,
            length: { maximum: Settings.correspondence_message_max_length,
                      message: "Message is too long (maximum is 5000 characters)" }

  validates :contact_requested,
            inclusion: { in: %w[yes no],
                         if: proc { contact_requested.present? } }

  jsonb_accessor :content,
                 name: :string,
                 email: :string,
                 category: :string,
                 topic: :string,
                 message: :text,
                 contact_requested: :string

  before_validation :set_uuid, on: :create

  def topic_present?
    errors.add("topic", "What are you contacting the Ministry of Justice about? can't be blank") if topic.blank?
    topic.present?
  end

  def authenticated?
    !authenticated_at.nil?
  end

  def authenticate!
    unless authenticated?
      self.authenticated_at = Time.zone.now
      save!
    end
  end

  def confirmation_code
    @confirmation_code ||= uuid.split("-")[1, 2].join("-")
  end

  def self.all_by_message(message)
    where("content @> ?", { message: }.to_json)
  end

  def self.first_by_message(message)
    all_by_message(message).first
  end

private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end
end
