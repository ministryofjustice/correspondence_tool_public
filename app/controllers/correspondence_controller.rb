class CorrespondenceController < ApplicationController

  rescue_from Redis::CannotConnectError do
    render :file => 'public/500-redis-down.html', :status => 500, :layout => false
  end

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(correspondence_params)

    if @correspondence.save
      EmailCorrespondenceJob.perform_later(@correspondence)
      render 'correspondence/confirmation'
    else
      render :new
    end
  end

  private

  def category_attribute
    case params[:smoke_test]
    when 'true' then 'smoke_test'
    else 'general_enquiries'
    end
  end

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :email_confirmation,
      :topic,
      :message,
      :smoke_test
    ).merge({ category: category_attribute })
  end
end
