class CorrespondenceController < ApplicationController

  def new
    @correspondence = Correspondence.new
  end

  def create
    @correspondence = Correspondence.new(general_enquiry_attributes)

    if @correspondence.valid?
      EmailCorrespondenceJob.perform_later(YAML.dump(@correspondence))
      Rails.configuration.correspondence_logger.info(
        [
          DateTime.now.to_s,
          @correspondence.name,
          @correspondence.email,
          @correspondence.topic,
          @correspondence.message.gsub('\\', '\\\\').gsub("\n", '\\n').gsub("\r", '\\r')
        ].join("\t")
      )
      render 'correspondence/confirmation'
    else
      render :new
    end
  end

  private

  def general_enquiry_attributes
    correspondence_params.merge(
      type: 'general_enquiries'
    )
  end

  def correspondence_params
    params.require(:correspondence).permit(
      :name,
      :email,
      :topic,
      :message
      ) 
  end

end
