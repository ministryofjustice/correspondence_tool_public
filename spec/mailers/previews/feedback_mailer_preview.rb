# Preview all emails at http://localhost:3000/rails/mailers/feedback_mailer
class FeedbackMailerPreview < ActionMailer::Preview
  def new_feedback_preview
    @preview_feedback = FactoryGirl.build(:feedback)
    FeedbackMailer.new_feedback(@preview_feedback)
  end
end