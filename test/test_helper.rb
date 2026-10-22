ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    TOKEN = "abcdefghijklmnopqrstuv".freeze

    setup { Presence.reset! }
  end
end

class ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  STREAM = "room:#{ActiveSupport::TestCase::TOKEN}".freeze

  private
    def sign_in(name = "Ana", token: TOKEN)
      post room_user_path(token), params: { name: }
    end
end
