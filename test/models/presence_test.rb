require "test_helper"

class PresenceTest < ActiveSupport::TestCase
  setup { @ana = User.new(id: "u1", name: "Ana") }

  test "join is fresh only once; leave reports the last connection" do
    assert Presence.join(TOKEN, @ana)
    assert_not Presence.join(TOKEN, @ana) # second tab
    assert_not Presence.leave(TOKEN, @ana)
    assert Presence.leave(TOKEN, @ana)
    assert_not Presence.leave(TOKEN, @ana) # no connection left to close
  end

  test "a user stays listed during the grace period and is removed by expire" do
    Presence.join(TOKEN, @ana)
    Presence.leave(TOKEN, @ana)
    assert_equal 1, Presence.count(TOKEN)

    assert Presence.expire(TOKEN, @ana)
    assert_equal 0, Presence.count(TOKEN)
    assert_not Presence.expire(TOKEN, @ana)
  end

  test "coming back within the grace period is not a fresh join and cancels the expiry" do
    Presence.join(TOKEN, @ana)
    Presence.leave(TOKEN, @ana)

    assert_not Presence.join(TOKEN, @ana)
    assert_not Presence.expire(TOKEN, @ana)
    assert_equal 1, Presence.count(TOKEN)
  end
end
