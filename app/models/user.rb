class User < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
end
