# The room's Turbo stream, plus presence: joining or leaving updates everyone's "online" list.
class RoomChannel < Turbo::StreamsChannel
  def subscribed
    super
    return if subscription_rejected?

    stream = verified_stream_name_from_params
    return reject unless stream.start_with?("room:")

    @token = stream.delete_prefix("room:")
    if Presence.join(@token, current_user)
      Turbo::StreamsChannel.broadcast_append_to "room", @token, target: "people", partial: "users/user", locals: { user: current_user }
      broadcast_count
    end
  end

  def unsubscribed
    return unless @token && Presence.leave(@token, current_user)

    Turbo::StreamsChannel.broadcast_remove_to "room", @token, target: current_user.dom_id
    broadcast_count
  end

  private
    def broadcast_count
      Turbo::StreamsChannel.broadcast_update_to "room", @token, target: "online-count", html: Presence.count(@token).to_s
    end
end
