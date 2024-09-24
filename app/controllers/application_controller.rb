class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def not_found
    render "errors/not_found", status: :not_found
  end

  def internal_server_error
    render "errors/internal_error", status: :internal_server_error
  end
end
