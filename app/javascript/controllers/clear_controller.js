import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]

  characterCounter = document.getElementById('character-counter');
  clearInput() {
    if (this.element) {
      this.element.reset();
      this.characterCounter.innerHTML = this.inputTarget.getAttribute('maxlength');
    }
  }
}