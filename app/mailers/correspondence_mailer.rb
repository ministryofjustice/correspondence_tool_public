class CorrespondenceMailer < ApplicationMailer

  def new_correspondence(correspondence)
    @correspondence = correspondence
    mail to: 'edward.andress@digital.justice.gov.uk', subject: "New #{@correspondence.type} - #{@correspondence.sub_type}"
  end

end
