class Correspondence

  include ActiveModel::Model
  include ActiveModel::Validations

  validates_presence_of :name, :email, :type, :message, :topic, :email_confirmation
  validates_confirmation_of :email, :case_sensitive => false
  validates_inclusion_of :type, in: Settings.correspondence_types
  validates_inclusion_of :topic, in: Settings.correspondence_topics

  attr_accessor :name, :email, :email_confirmation, :type, :topic, :message

end
