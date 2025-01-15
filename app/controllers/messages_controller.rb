class MessagesController < ApplicationController
  def create
    @message = Message.new(
      content: params[:content],
      user: User.find_by(id: session[:user_id]),
      room: Room.find_by(name: params[:room_name])
    )

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "messages", partial: "messages/message", locals: { message: @message, from_stream: false }
          )
        end
        format.html { redirect_to chat_show_path(params[:room_name]) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "form-errors",
            partial: "shared/flash", locals: { alert: "Erro ao enviar mensagem" }
          )
        end
        format.html do
          flash[:alert] = "Erro ao enviar mensagem"
          redirect_to chat_show_path(params[:room_name])
        end
      end
    end
  end
end
