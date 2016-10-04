class FeedbackController < ApplicationController

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.valid?
      EmailFeedbackJob.perform_later(YAML.dump(@feedback))
      log_feedback
      redirect_to correspondence_url, notice: 'Feedback submitted'
    else
      render :new
    end
  end

  private

  def log_feedback
    Rails.configuration.feedback_logger.info(
      {
        feedback:
          {
            timestamp: DateTime.now.to_s,
            rating: @feedback.rating.humanize,
            comment:   @feedback.comment
              .gsub('\\', '\\\\')
              .gsub("\n", '\\n')
              .gsub("\r", '\\r')
          }
      }.to_json
    )
  end

  def feedback_params
    params.require(:feedback).permit(
      :rating,
      :comment
      ) 
  end

end
