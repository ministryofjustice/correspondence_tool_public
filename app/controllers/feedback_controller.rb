class FeedbackController < ApplicationController
  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      FeedbackMailer.new_feedback(@feedback).deliver_later
      render 'feedback/confirmation'
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :ease_of_use,
      :completeness,
      :comment
    )
  end
end
