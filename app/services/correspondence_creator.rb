class CorrespondenceCreator

  attr_reader :result, :correspondence

  def initialize(params)
    if params['contact_requested'] == 'no'
      @result = :no_op
    else
      @correspondence = create_correspondence(params)
    end
  end

  private

  def create_correspondence(params)
    correspondence = Correspondence.new(params)
    if correspondence.save
      EmailConfirmationJob.perform_later(correspondence)
      @result = :success
    else
      @result = :validation_error
    end
    correspondence
  end
end
