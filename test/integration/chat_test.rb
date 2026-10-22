require "test_helper"

class ChatTest < ActionDispatch::IntegrationTest
  test "home renders" do
    get root_path
    assert_response :success
    assert_select "h1", /Converse/
  end

  test "creating a room redirects to an unguessable token" do
    post rooms_path
    assert_match %r{/r/[A-Za-z0-9_-]{22}\z}, response.location
  end

  test "enter accepts a code or a full link, rejects junk" do
    get enter_path, params: { code: " #{TOKEN} " }
    assert_redirected_to room_path(TOKEN)

    get enter_path, params: { code: "https://chat.example.com/r/#{TOKEN}/" }
    assert_redirected_to room_path(TOKEN)

    get enter_path, params: { code: "nope" }
    assert_redirected_to root_path
  end

  test "room asks for a name first, then shows the chat" do
    get room_path(TOKEN)
    assert_select "form[action=?]", room_user_path(TOKEN)

    sign_in "Ana"
    assert_redirected_to room_path(TOKEN)
    follow_redirect!
    assert_select "#messages"
    assert_select "turbo-cable-stream-source[channel=RoomChannel]"
  end

  test "invalid names are rejected" do
    sign_in "A"
    assert_response :unprocessable_content
    sign_in "x" * 21
    assert_response :unprocessable_content
  end

  test "messages are broadcast to the room and never stored" do
    sign_in "Ana"

    assert_broadcasts STREAM, 1 do
      post room_messages_path(TOKEN), params: { body: "  <b>oi</b>  " }
    end
    assert_response :no_content

    assert_includes JSON.parse(broadcasts(STREAM).last), "&lt;b&gt;oi&lt;/b&gt;", "message body must be HTML-escaped"
  end

  test "empty, oversized and anonymous messages are refused" do
    post room_messages_path(TOKEN), params: { body: "oi" }
    assert_response :unauthorized

    sign_in
    assert_no_broadcasts STREAM do
      post room_messages_path(TOKEN), params: { body: "   " }
      assert_response :unprocessable_content
      post room_messages_path(TOKEN), params: { body: "x" * (Message::MAX_LENGTH + 1) }
      assert_response :unprocessable_content
    end
  end

  test "theme cookie is rendered on <html>, junk values fall back to system" do
    cookies[:theme] = "dark"
    get root_path
    assert_select "html[data-theme=dark]"
    assert_select "input[name=theme][value=dark][checked]"

    cookies[:theme] = "<script>"
    get root_path
    assert_select "html[data-theme]", count: 0
  end

  test "malformed room tokens do not route" do
    get "/r/short"
    assert_response :not_found
  end
end
