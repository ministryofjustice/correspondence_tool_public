class CorrespondenceController < ApplicationController

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(correspondence_params)

    if @correspondence.valid?
      # TODO: create and send email
      CorrespondenceMailer.new_correspondence(@correspondence).deliver_now
      render 'correspondence/confirmation'
    else
      # TODO: show errors
      render :new
    end
  end

  private

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :email_confirmation,
      :type,
      :sub_type,
      :message
      ) 
  end

end
