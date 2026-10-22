require "test_helper"

class RoomChannelTest < ActionCable::Channel::TestCase
  setup { @ana = User.new(id: "u1", name: "Ana") }

  test "presence counts connections, not tabs" do
    stub_connection current_user: @ana
    signed = Turbo::StreamsChannel.signed_stream_name([ "room", TOKEN ])

    subscribe signed_stream_name: signed
    assert subscription.confirmed?
    assert_equal [ @ana ], Presence.users(TOKEN)

    subscribe signed_stream_name: signed # second tab
    unsubscribe
    assert_equal 1, Presence.count(TOKEN)
  end

  test "rejects forged stream names" do
    stub_connection current_user: @ana
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
