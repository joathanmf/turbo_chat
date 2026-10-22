import { Controller } from "@hotwired/stimulus"

// System / light / dark. The cookie lets the server render the right theme on the next page load.
export default class extends Controller {
  pick({ target: { value } }) {
    const secure = location.protocol === "https:" ? "; secure" : ""
    if (value === "system") {
      document.cookie = `theme=; path=/; max-age=0; samesite=lax${secure}`
      delete document.documentElement.dataset.theme
    } else {
      document.cookie = `theme=${value}; path=/; max-age=31536000; samesite=lax${secure}`
      document.documentElement.dataset.theme = value
    }
  }
}
