class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: Settings["#{@correspondence.type}_email"],
         subject: "New #{@correspondence.type.humanize} - #{@correspondence.topic.humanize}"
  end

end
