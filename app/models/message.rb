# A chat message. Built, broadcast once, then forgotten: never stored.
class Message < Data.define(:id, :author, :body, :sent_at)
  MAX_LENGTH = 1000
  UUID = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  # The id comes from the sender's browser (optimistic UI), so its broadcast replaces the pending copy.
  def self.build(author:, body:, id: nil)
    body = body.to_s.strip
    id = id.to_s.match?(UUID) ? id.to_s : SecureRandom.uuid
    new(id:, author:, body:, sent_at: Time.current) if body.length.between?(1, MAX_LENGTH)
  end

  # Scoped by author: a client-chosen id can only ever replace that author's own messages.
  def dom_id = "message_#{author.id}_#{id}"
end
