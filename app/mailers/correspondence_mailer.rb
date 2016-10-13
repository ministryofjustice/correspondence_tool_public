class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: Settings["#{@correspondence.category}_email"]
         subject: "New #{@correspondence.category.humanize} - #{@correspondence.topic.humanize}"
  end

end
