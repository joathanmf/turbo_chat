# Who is in each room right now, counted per open connection (a user may have several tabs).
# ponytail: in-process memory, matches the async cable adapter. Move to Redis sets if you run several servers.
module Presence
  @rooms = {} # token => { user_id => [user, connections] }
  @lock = Mutex.new

  class << self
    # True when this is the user's first connection to the room.
    def join(token, user)
      @lock.synchronize do
        entry = ((@rooms[token] ||= {})[user.id] ||= [ user, 0 ])
        entry[1] += 1
        entry[1] == 1
      end
    end

    # True when the user's last connection to the room is gone.
    def leave(token, user)
      @lock.synchronize do
        room = @rooms[token]
        entry = room&.[](user.id)
        next false unless entry

        entry[1] -= 1
        next false if entry[1].positive?

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
