class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: Rails.application.secrets.email, subject: "New #{@correspondence.type} - #{@correspondence.sub_type}"
  end

end
