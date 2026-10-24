class MessagesController < ApplicationController
  rate_limit to: 20, within: 10.seconds, by: -> { current_user&.id || request.remote_ip }, with: -> { head :too_many_requests }

  # Relays the message to everyone in the room (sender included) and keeps nothing.
  def create
    return head :unauthorized unless current_user

    message = Message.build(author: current_user, body: params[:body], id: params[:id])
    return head :unprocessable_content unless message

    Turbo::StreamsChannel.broadcast_append_to "room", params[:token],
      target: "messages", partial: "messages/message", locals: { message: }
    head :no_content
  end
end
