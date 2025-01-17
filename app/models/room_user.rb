class RoomUser < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :user_id, uniqueness: { scope: :room_id }

  after_create_commit do
    broadcast_append_later_to(
      "online_users_room_#{room.name}",
      target: "users",
      partial: "users/user",
      locals: { user: user }
    )
  end
end
