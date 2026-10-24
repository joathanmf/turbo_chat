# Who is in each room right now, counted per open connection (a user may have several tabs).
# A user whose last connection closes stays listed until `expire`, so a page refresh isn't announced as leave + join.
# ponytail: in-process memory, matches the async cable adapter. Move to Redis sets if you run several servers.
module Presence
  @rooms = {} # token => { user_id => [user, connections] }
  @lock = Mutex.new

  class << self
    # True when the user wasn't in the room (not even inside the leave grace period).
    def join(token, user)
      @lock.synchronize do
        room = (@rooms[token] ||= {})
        fresh = !room.key?(user.id)
        (room[user.id] ||= [ user, 0 ])[1] += 1
        fresh
      end
    end

    # True when the user's last connection is gone; call `expire` after a grace period.
    def leave(token, user)
      @lock.synchronize do
        entry = @rooms.dig(token, user.id)
        next false unless entry&.last&.positive?

        entry[1] -= 1
        entry[1].zero?
      end
    end

    # Removes the user if they still have no connection. True when removed.
    def expire(token, user)
      @lock.synchronize do
        room = @rooms[token]
        next false unless room&.dig(user.id, 1)&.zero?

        room.delete(user.id)
        @rooms.delete(token) if room.empty?
        true
      end
    end

    def users(token) = @lock.synchronize { @rooms.fetch(token, {}).values.map(&:first) }
    def count(token) = @lock.synchronize { @rooms.fetch(token, {}).size }
    def reset! = @lock.synchronize { @rooms.clear }
  end
end
