import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

// Custom stream action broadcast by RoomChannel#typing; the room controller shows it.
Turbo.StreamActions.typing = function () {
  document.dispatchEvent(new CustomEvent("room:typing", { detail: { id: this.dataset.user, name: this.dataset.name } }))
}
