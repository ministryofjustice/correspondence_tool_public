class CorrespondenceController < ApplicationController

  rescue_from Redis::CannotConnectError do
    render :file => 'public/500-redis-down.html', :status => 500, :layout => false
  end

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(general_enquiry_attributes)

    if @correspondence.save
      EmailCorrespondenceJob.perform_later(@correspondence)
      render 'correspondence/confirmation'
    else
      render :new
    end
  end

  private

  def general_enquiry_attributes
    correspondence_params.merge(category: 'general_enquiries')
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
