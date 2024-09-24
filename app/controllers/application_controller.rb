class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
