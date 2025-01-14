class ChatController < ApplicationController
  before_action :fetch_user_from_session, only: :show
  def index
    @room = Room.new
  end

  def show
    @room = Room.find_by!(name: params[:room_name])
    @messages = @room.messages.includes(:user).order(:created_at)
  end

  def create
    @room = Room.new

    if @room.save
      redirect_to chat_show_path(@room.name)
    else
      redirect_to root_path, alert: "Erro ao criar chat"
    end
  end

  def enter
    if Room.find_by(name: params[:room_name])
      redirect_to chat_show_path(params[:room_name])
    else
      redirect_to root_path, alert: "Código de chat inválido"
    end
  end

  private

  def fetch_user_from_session
    unless session[:user_id] && User.exists?(session[:user_id])
      redirect_to chat_users_new_path(room_name: params[:room_name])
    end
  end
end
