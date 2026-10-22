require "test_helper"

class PresenceTest < ActiveSupport::TestCase
  test "join and leave report only first and last connection" do
    ana = User.new(id: "u1", name: "Ana")

    assert Presence.join(TOKEN, ana)
    assert_not Presence.join(TOKEN, ana)
    assert_not Presence.leave(TOKEN, ana)
    assert Presence.leave(TOKEN, ana)
    assert_not Presence.leave(TOKEN, ana)
    assert_equal 0, Presence.count(TOKEN)
  end
end
