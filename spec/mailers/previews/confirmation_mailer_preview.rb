# Preview all emails at http://localhost:3000/rails/mailers/correspondence_mailer
class ConfirmationMailerPreview < ActionMailer::Preview
  def new_confirmation_preview
    @preview_correspondence = FactoryBot.build(:correspondence)
    ConfirmationMailer.new_confirmation(@preview_correspondence)
  end
end
