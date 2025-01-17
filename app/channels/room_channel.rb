class RoomChannel < ApplicationCable::Channel
  include ActionView::RecordIdentifier

  def subscribed; end

  def unsubscribed
    room = Room.find_by(name: params[:room_name])
    current_user = User.find_by(id: params[:user_id])

    if room && current_user
      RoomUser.where(user: current_user, room: room).delete_all
      broadcast_remove_user(room, current_user)
    end
  end

  private

  def broadcast_remove_user(room, user)
    Turbo::StreamsChannel.broadcast_remove_to(
      "online_users_room_#{room.name}",
      target: dom_id(user)
    )
  end
end
