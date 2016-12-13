class ConfirmationMailer < ApplicationMailer

  def new_confirmation(correspondence)
    @correspondence = correspondence
    mail to: @correspondence.email,
      from: 'noreply@digital.justice.gov.uk',
      subject: "We have received your enquiry"
  end

end

