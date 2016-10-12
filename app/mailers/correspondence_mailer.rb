class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: ENV["#{@correspondence.category.upcase}_EMAIL"],
         subject: "New #{@correspondence.category.humanize} - #{@correspondence.topic.humanize}"
  end

end
