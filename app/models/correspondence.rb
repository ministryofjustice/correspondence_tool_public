class Correspondence

  include ActiveModel::Model
  include ActiveModel::Validations

  validates_presence_of :topic,
                        :message,
                        :name,
                        :email,
                        :email_confirmation,
                        :type

  validates :email, confirmation: { case_sensitive: false }

  validates_format_of :email, with: /@/,
    if: Proc.new { email.present? }

  validates_inclusion_of :type,
    in: Settings.correspondence_types,
    if: Proc.new { type.present? }
  validates_inclusion_of :topic,
    in: Settings.correspondence_topics,
    if: Proc.new { topic.present? }

  attr_accessor :name, :email, :type, :topic, :message

end
