import { Controller } from "@hotwired/stimulus"

const time = new Intl.DateTimeFormat(undefined, { hour: "2-digit", minute: "2-digit" })

export default class extends Controller {
  static targets = [ "thread", "message", "form", "input", "error", "info", "link" ]
  static values = { me: String }

  // Every message arrives over the cable, ours included. Style it, then keep the view pinned to the bottom.
  messageTargetConnected(el) {
    const thread = this.threadTarget
    const nearBottom = thread.scrollHeight - thread.scrollTop - thread.clientHeight - el.offsetHeight < 120
    const mine = el.dataset.author === this.meValue
    const prev = el.previousElementSibling

    el.classList.toggle("mine", mine)
    el.classList.toggle("cont", prev?.dataset.author === el.dataset.author)
    const stamp = el.querySelector("time")
    stamp.textContent = time.format(new Date(stamp.dateTime))

    if (mine || nearBottom) thread.scrollTo({ top: thread.scrollHeight, behavior: "smooth" })
  }

  sent({ detail: { success, fetchResponse } }) {
    if (success) {
      this.formTarget.reset()
      this.errorTarget.hidden = true
      this.inputTarget.focus()
    } else {
      const status = fetchResponse?.response?.status
      this.errorTarget.textContent = status === 429 ? "Devagar! Espere alguns segundos." : "Não foi possível enviar. Tente de novo."
      this.errorTarget.hidden = false
    }
  }

  openInfo() {
    this.infoTarget.showModal()
  }

  async share(event) {
    const url = this.linkTarget.value
    if (navigator.share) {
      try { await navigator.share({ title: "Turbo Chat", text: "Entra na minha sala:", url }) } catch {}
      return
    }
    await navigator.clipboard.writeText(url)
    const button = event.currentTarget
    button.textContent = "Link copiado"
    setTimeout(() => (button.textContent = "Compartilhar"), 2000)
  }
}
