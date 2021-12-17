class CorrespondenceController < ApplicationController

  rescue_from Redis::CannotConnectError do
    render :file => 'public/500-redis-down.html', :status => 500, :layout => false
  end

  def start; end

  def create
    creator = CorrespondenceCreator.new(correspondence_params)
    @correspondence = creator.correspondence
    case creator.result
    when :success
      redirect_to correspondence_confirmation_path(@correspondence.uuid)
    when :no_op
      redirect_to Settings.moj_home_page
    when :validation_error
      @search_api_client = GovUkSearchApi::Client.new(@correspondence.topic)
      @search_result = @search_api_client.search
      render :search
    end
  end

  def confirmation
    @correspondence = Correspondence.find_by_uuid(params[:uuid])
  end

  def topic
    @correspondence = Correspondence.new
  end

  def search
    @correspondence = Correspondence.new(topic: search_params[:topic])
    if @correspondence.topic_present?
      @correspondence = Correspondence.new(topic: search_params[:topic])
      @search_api_client = GovUkSearchApi::Client.new(@correspondence.topic)
      @search_result = @search_api_client.search
    else
      render :topic
    end
  end

  def authenticate
    @correspondence = Correspondence.where(uuid: params[:uuid]).first
    if @correspondence.nil?
      render file:  Rails.root.join('/public/404.html'), status: 404, layout: false
    else
      @correspondence.authenticate!
      CorrespondenceMailer.new_correspondence(@correspondence).deliver_later
    end
  end

  def t_and_c
    render
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
      :topic,
      :message,
      :smoke_test,
      :contact_requested
    ).merge({ category: category_attribute })
  end

  def search_params
    params.require(:correspondence).permit(:topic)
  end
end
