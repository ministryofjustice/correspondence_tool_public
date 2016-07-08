class Correspondence

  include ActiveModel::Model
  include ActiveModel::Validations

  validates_presence_of :name, :email, :type, :message
  validates_confirmation_of :email

  attr_accessor :name, :email, :email_confirmation, :type, :sub_type, :message

end