class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validates :content, presence: true, length: { minimum: 1, maximum: 1024 }

  after_create_commit do
    broadcast_append_to room, target: "messages", partial: "messages/message", locals: { message: self, from_stream: true }
  end
end
