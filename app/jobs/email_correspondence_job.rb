require 'correspondence'

class EmailCorrespondenceJob < ApplicationJob

  queue_as :mailers

  def perform(correspondence_yaml)
    correspondence = YAML.load(correspondence_yaml)
    CorrespondenceMailer.new_correspondence(correspondence).deliver_now
  end

end
