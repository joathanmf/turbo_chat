class MessagesController < ApplicationController
  def create
    @message = Message.new(
      content: params[:content],
      user: User.find_by(id: session[:user_id]),
      room: Room.find_by(name: params[:room_name])
    )

    if @message.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(
          "messages", partial: "messages/message", locals: { message: @message, from_stream: false }
        ) }
        format.html { redirect_to chat_show_path(params[:room_name]) }
      end
    end
  end
end
