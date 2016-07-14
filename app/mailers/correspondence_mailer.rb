class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    mail to: 'email@email.com', subject: 'New FOI Request'
  end

end
