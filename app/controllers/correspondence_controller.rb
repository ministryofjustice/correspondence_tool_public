class CorrespondenceController < ApplicationController

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(correspondence_params)

    if @correspondence.valid?
      EmailCorrespondenceJob.perform_later(YAML.dump(@correspondence))
      render 'correspondence/confirmation'
    else
      render :new
    end
  end

  def start
    render :start
  end

  def step_topic
    @correspondence = Correspondence.new
    render :step_topic
  end

  def step_message
    @correspondence = Correspondence.new
    render :step_message
  end

  def step_name
    @correspondence = Correspondence.new
    render :step_name
  end

  end

  private

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :email_confirmation,
      :type,
      :topic,
      :message
      ) 
  end

end
