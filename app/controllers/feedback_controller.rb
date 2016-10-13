class FeedbackController < ApplicationController

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      EmailFeedbackJob.perform_later(@feedback)
      redirect_to correspondence_url, notice: 'Feedback submitted'
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment) 
  end

end
