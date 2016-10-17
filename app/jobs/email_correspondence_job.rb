class EmailCorrespondenceJob < ApplicationJob

  queue_as :mailers

  def perform(correspondence_id)
    correspondence = Correspondence.find(correspondence_id)
    CorrespondenceMailer.new_correspondence(correspondence).deliver_now
  end
end
