class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: ENV['CORRESPONDENCE_EMAIL_TO'], subject: "New #{@correspondence.type} - #{@correspondence.topic}"
  end

end
