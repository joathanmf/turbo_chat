require "test_helper"

class RoomChannelTest < ActionCable::Channel::TestCase
  setup do
    @ana = User.new(id: "u1", name: "Ana")
    @signed = Turbo::StreamsChannel.signed_stream_name([ "room", TOKEN ])
    stub_connection current_user: @ana
  end

  test "joining lists the user, updates the count and posts a notice" do
    assert_broadcasts "room:#{TOKEN}", 3 do
      subscribe signed_stream_name: @signed
    end
    assert subscription.confirmed?
    assert_equal [ @ana ], Presence.users(TOKEN)
    assert_includes JSON.parse(broadcasts("room:#{TOKEN}").last), "entrou"
  end

  test "a second tab is not announced; leaving waits for the grace period" do
    subscribe signed_stream_name: @signed
    assert_no_broadcasts "room:#{TOKEN}" do
      subscribe signed_stream_name: @signed # second tab
      unsubscribe
    end
    assert_equal 1, Presence.count(TOKEN)
  end

  test "announce leave removes the user and posts a notice" do
    RoomChannel.announce(TOKEN, @ana, :leave)
    html = broadcasts("room:#{TOKEN}").map { JSON.parse(it) }.join
    assert_includes html, %(action="remove" target="user_u1")
    assert_includes html, "saiu"
  end

  test "rejects forged stream names" do
    subscribe signed_stream_name: "forged"
    assert subscription.rejected?
    assert_equal 0, Presence.count(TOKEN)
  end
end

class ConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  test "rejects visitors without a name in the session" do
    assert_reject_connection { connect }
  end
end
