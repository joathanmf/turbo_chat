class Room < ApplicationRecord
  has_many :messages, dependent: :destroy

  before_create :set_name

  def users
    User.where(id: messages.pluck(:user_id))
  end

  private

  def set_name
    self.name = SecureRandom.hex(4)
  end
end
