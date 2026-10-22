# A chat participant. Lives only in the visitor's encrypted session cookie.
class User < Data.define(:id, :name)
  NAME_LENGTH = 2..20

  def self.from_session(session)
    new(id: session["user_id"], name: session["user_name"]) if session && session["user_id"] && session["user_name"]
  end

  def self.clean_name(raw)
    name = raw.to_s.squish
    name if NAME_LENGTH.cover?(name.length)
  end

  def initial = name[0].upcase
  def dom_id = "user_#{id}"
end
