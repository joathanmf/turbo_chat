import { Controller } from "@hotwired/stimulus";
import consumer from "../channels/consumer";

export default class extends Controller {
  static values = { roomName: String, userId: String };

  connect() {
    if (!this.roomNameValue || !this.userIdValue) {
      return;
    }

    this.chatChannel = consumer.subscriptions.create(
      {
        channel: "RoomChannel",
        room_name: this.roomNameValue,
        user_id: this.userIdValue,
      },
      {
        connected: this.handleConnected.bind(this),
        disconnected: this.handleDisconnected.bind(this),
      }
    );

    console.log(`Connected to RoomChannel: ${this.roomNameValue}`);
  }

  disconnect() {
    if (this.chatChannel) {
      consumer.subscriptions.remove(this.chatChannel);
      console.log(`Disconnected from RoomChannel: ${this.roomNameValue}`);
    }
  }

  // Callback when the connection is established
  handleConnected() {
    console.log("Successfully connected to the WebSocket for the room.");
  }

  // Callback when the connection is terminated
  handleDisconnected() {
    console.log("Disconnected from the WebSocket.");
  }
}
