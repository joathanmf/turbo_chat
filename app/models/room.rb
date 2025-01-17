class Room < ApplicationRecord
  has_many :messages, dependent: :destroy

  has_many :room_users, dependent: :destroy
  has_many :users, through: :room_users

  before_create :set_name

  private

  def set_name
    self.name = SecureRandom.hex(4)
  end
end
