class UsersController < ApplicationController
  rate_limit to: 10, within: 1.minute,
    with: -> { redirect_to room_path(params[:token]), alert: "Muitas tentativas. Tente de novo em instantes." }

  def create
    @token = params[:token]

    if (name = User.clean_name(params[:name]))
      session[:user_id] ||= SecureRandom.alphanumeric(16)
      session[:user_name] = name
      redirect_to room_path(@token)
    else
      flash.now[:alert] = "Use de #{User::NAME_LENGTH.min} a #{User::NAME_LENGTH.max} caracteres."
      render :new, status: :unprocessable_content
    end
  end
end
