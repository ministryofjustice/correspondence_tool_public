class Correspondence

  include ActiveModel::Model
  include ActiveModel::Validations

  validates_presence_of :name, :email, :type, :message, :topic
  validates_inclusion_of :type, in: Settings.correspondence_types, if: Proc.new { |correspondence| correspondence.type.present? }
  validates_inclusion_of :topic, in: Settings.correspondence_topics, if: Proc.new { |correspondence| correspondence.topic.present? }

  attr_accessor :name, :email, :email_confirmation, :type, :topic, :message

end
