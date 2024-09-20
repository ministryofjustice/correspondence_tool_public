class CorrespondenceController < ApplicationController
  rescue_from Redis::CannotConnectError do
    render file: "public/500-redis-down.html", status: :internal_server_error, layout: false
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
      @search_results = search_results(@search_api_client.search)
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
      @search_results = search_results(@search_api_client.search)
    else
      render :topic
    end
  end

  def authenticate
    @correspondence = Correspondence.where(uuid: params[:uuid]).first
    if @correspondence.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
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
    "general_enquiries"
  end

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :topic,
      :message,
      :contact_requested,
    ).merge({ category: category_attribute })
  end

  def search_params
    params.require(:correspondence).permit(:topic)
  end

  def search_results(search)
    results = search.result_items.each_with_index.map do |item, index|
      view_context.govuk_link_to(
        item.title,
        item.link,
        onclick: "ga('send', 'event', 'External Link - Results', '#{index + 1} - #{item.title} - #{item.link}')",
      )
    end

    results << view_context.govuk_link_to(
      t(".more_results"),
      @search_api_client.more_results_url,
      onclick: "ga('send', 'event', 'External Link - Results', '#{t('.more_results')}')",
    )

    results
  end
end
