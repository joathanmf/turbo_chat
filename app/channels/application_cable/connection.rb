module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    # Identity comes from the encrypted session cookie, never from client params.
    def connect
      session = cookies.encrypted[Rails.application.config.session_options[:key]]
      self.current_user = User.from_session(session) || reject_unauthorized_connection
    end
  end
end
