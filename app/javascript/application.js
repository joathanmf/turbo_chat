import { Turbo, cable } from "@hotwired/turbo-rails"
import "controllers"

// Leaving the site can park the page in the back/forward cache with its WebSocket still open, so the person
// would look "online" for minutes. Close it on the way out; on the way back, reconnecting resubscribes and the
// server sends the current presence again.
let consumer
cable.getConsumer().then(c => (consumer = c))
addEventListener("pagehide", () => consumer?.disconnect())
addEventListener("pageshow", event => { if (event.persisted) consumer?.connect() })

// Custom stream action broadcast by RoomChannel#typing; the room controller shows it.
Turbo.StreamActions.typing = function () {
  document.dispatchEvent(new CustomEvent("room:typing", { detail: { id: this.dataset.user, name: this.dataset.name } }))
}
