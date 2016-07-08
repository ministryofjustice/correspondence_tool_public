class CorrespondenceController < ApplicationController

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(correspondence_params)

    if @correspondence.valid?
      render 'correspondence/confirmation'
    else
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
