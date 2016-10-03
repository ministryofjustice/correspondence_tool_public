class CorrespondenceController < ApplicationController

  rescue_from Redis::CannotConnectError do
    render :file => 'public/500-redis-down.html', :status => 500, :layout => false
  end

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(general_enquiry_attributes)

    if @correspondence.valid?
      EmailCorrespondenceJob.perform_later(YAML.dump(@correspondence))
      log_correspondence
      render 'correspondence/confirmation'
    else
      render :new
    end
  end

  private

  def log_correspondence
    Rails.configuration.correspondence_logger.info(
      {
        correspondence:
          {
            timestamp: DateTime.now.to_s,
            name:      @correspondence.name,
            email:     @correspondence.email,
            topic:     @correspondence.topic,
            message:   @correspondence.message
              .gsub('\\', '\\\\')
              .gsub("\n", '\\n')
              .gsub("\r", '\\r')
          }
      }.to_json
    )
  end

  def general_enquiry_attributes
    correspondence_params.merge(
      type: 'general_enquiries'
    )
  end

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :email_confirmation,
      :topic,
      :message
      ) 
  end

end
