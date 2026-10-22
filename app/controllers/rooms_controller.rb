class RoomsController < ApplicationController
  rate_limit to: 10, within: 1.minute, only: :create,
    with: -> { redirect_to root_path, alert: "Muitas salas em pouco tempo. Tente de novo em instantes." }

  def new
  end

  # A room is just an unguessable token (128 bits). It exists while someone is in it.
  def create
    redirect_to room_path(SecureRandom.urlsafe_base64(16))
  end

  # Accepts the bare code or the full shared link.
  def enter
    token = params[:code].to_s.strip.delete_suffix("/")[/[A-Za-z0-9_-]{22}\z/]
    if token
      redirect_to room_path(token)
    else
      redirect_to root_path, alert: "Código ou link inválido."
    end
  end

  def show
    @token = params[:token]
    render "users/new" unless current_user
  end
end
