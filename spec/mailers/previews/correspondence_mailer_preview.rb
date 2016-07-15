# Preview all emails at http://localhost:3000/rails/mailers/correspondence_mailer
class CorrespondenceMailerPreview < ActionMailer::Preview
  def new_correspondence_preview
    @preview_correspondence = FactoryGirl.build(:correspondence)
    CorrespondenceMailer.new_correspondence(@preview_correspondence)
  end
end