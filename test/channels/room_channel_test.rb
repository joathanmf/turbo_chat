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

  # Regression: the async adapter registers the stream on another thread, so the joiner used to miss
  # their own join broadcast and kept seeing "0 online" (or a list without themselves).
  test "the subscriber gets the current list directly, themselves included" do
    Presence.join(TOKEN, User.new(id: "u2", name: "Bia"))
    subscribe signed_stream_name: @signed

    snapshot = transmissions.last
    assert_includes snapshot, %(action="update" target="online-count"><template>2</template>)
    assert_includes snapshot, %(id="user_u1")
    assert_includes snapshot, %(id="user_u2")
    assert_includes snapshot, "entrou"
    assert_not_includes RoomChannel.action_methods, "transmit_presence"
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

  test "typing is relayed to the room (escaped), at most once per second per connection" do
    stub_connection current_user: User.new(id: "u2", name: %(<b>"Bia"</b>))
    subscribe signed_stream_name: @signed

    assert_broadcasts "room:#{TOKEN}", 1 do
      perform :typing
      perform :typing # too soon: dropped
    end
    html = JSON.parse(broadcasts("room:#{TOKEN}").last)
    assert_includes html, %(action="typing")
    assert_includes html, %(data-user="u2")
    assert_includes html, %(data-name="&lt;b&gt;&quot;Bia&quot;&lt;/b&gt;")
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
