import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clearInput() {
    if (this.element) {
      this.element.reset();
    }
  }
}