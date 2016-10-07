class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: ENV["#{@correspondence.type.upcase}_EMAIL"],
         subject: "New #{@correspondence.type.humanize} - #{@correspondence.topic.humanize}"
  end

end
