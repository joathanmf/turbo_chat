class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  private
    def current_user
      @current_user ||= User.from_session(session)
    end
end
