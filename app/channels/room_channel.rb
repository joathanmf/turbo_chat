# The room's Turbo stream, plus presence: joining or leaving updates the "online" list and posts a notice.
class RoomChannel < Turbo::StreamsChannel
  LEAVE_GRACE = 5 # seconds; a refresh or quick reconnect shouldn't post "saiu" + "entrou"

  def subscribed
    super
    return if subscription_rejected?

    stream = verified_stream_name_from_params
    return reject unless stream.start_with?("room:")

    @token = stream.delete_prefix("room:")
    self.class.announce(@token, current_user, :join) if Presence.join(@token, current_user)
  end

  def unsubscribed
    return unless @token && Presence.leave(@token, current_user)

    token, user = @token, current_user
    Concurrent::ScheduledTask.execute(LEAVE_GRACE) do
      Rails.application.executor.wrap { self.class.announce(token, user, :leave) if Presence.expire(token, user) }
    end
  end

  def self.announce(token, user, event)
    if event == :join
      Turbo::StreamsChannel.broadcast_append_to "room", token, target: "people", partial: "users/user", locals: { user: }
    else
      Turbo::StreamsChannel.broadcast_remove_to "room", token, target: user.dom_id
    end
    Turbo::StreamsChannel.broadcast_update_to "room", token, target: "online-count", html: Presence.count(token).to_s
    Turbo::StreamsChannel.broadcast_append_to "room", token, target: "messages", partial: "messages/notice", locals: { user:, event: }
  end
end
