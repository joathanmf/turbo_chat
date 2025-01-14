class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  private

  def record_not_found
    redirect_to root_path, alert: "Registro não encontrado"
  end
end
