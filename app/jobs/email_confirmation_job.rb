require 'correspondence'

class EmailConfirmationJob < ApplicationJob
  queue_as :mailers

  def perform(correspondence_id)
    correspondence = Correspondence.find(correspondence_id)
    ConfirmationMailer.new_confirmation(correspondence).deliver_now
  end
end
