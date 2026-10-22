# A chat message. Built, broadcast once, then forgotten: never stored.
class Message < Data.define(:id, :author, :body, :sent_at)
  MAX_LENGTH = 1000

  def self.build(author:, body:)
    body = body.to_s.strip
    new(id: SecureRandom.uuid, author:, body:, sent_at: Time.current) if body.length.between?(1, MAX_LENGTH)
  end
end
