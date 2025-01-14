class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(name: params[:user_name])

    if @user.save
      session[:user_id] = @user.id
      redirect_to chat_show_path(params[:room_name])
    else
      flash[:alert] = "Erro ao criar o usuário"
      render :new, status: :unprocessable_entity
    end
  end
end
