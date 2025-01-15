import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"];

  connect() {
    document.addEventListener("new_message", this.scrollToBottom.bind(this));
    this.scrollToBottom();
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
    }
  }
}
