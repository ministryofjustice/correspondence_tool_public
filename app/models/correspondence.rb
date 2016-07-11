class Correspondence

  include ActiveModel::Model
  include ActiveModel::Validations

  validates_presence_of :name, :email, :type, :message
  validates_confirmation_of :email
  validates_inclusion_of :type, in: Settings.correspondence_types
  validates_inclusion_of :sub_type, in: Settings.correspondence_sub_types, allow_nil: true

  attr_accessor :name, :email, :email_confirmation, :type, :sub_type, :message

end