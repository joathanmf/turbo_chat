class Room < ApplicationRecord
  has_many :messages, dependent: :destroy

  before_create :set_name

  private

  def set_name
    self.name = SecureRandom.hex(4)
  end
end
