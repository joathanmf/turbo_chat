import { Controller } from "@hotwired/stimulus"

const time = new Intl.DateTimeFormat(undefined, { hour: "2-digit", minute: "2-digit" })
const GAP = 10 * 60 * 1000 // show a centered timestamp after 10 min of silence, like Messages
const graphemes = new Intl.Segmenter()
// Only emoji (up to 3): rendered big, without a bubble.
const isJumbo = text => /\p{Extended_Pictographic}/u.test(text) &&
  !text.replace(/[\p{Extended_Pictographic}\p{Emoji_Modifier}‍️\s]/gu, "") &&
  [ ...graphemes.segment(text.replace(/\s/g, "")) ].length <= 3

export default class extends Controller {
  static targets = [ "thread", "message", "form", "input", "error", "info", "link" ]
  static values = { me: String }

  // Every message arrives over the cable, ours included. Style it, then keep the view pinned to the bottom.
  messageTargetConnected(el) {
    const thread = this.threadTarget
    const nearBottom = thread.scrollHeight - thread.scrollTop - thread.clientHeight - el.offsetHeight < 120
    const mine = el.dataset.author === this.meValue
    const prev = el.previousElementSibling
    const stamp = el.querySelector("time")
    const at = new Date(stamp.dateTime)
    const gap = !prev || at - new Date(prev.querySelector("time").dateTime) > GAP
    const grouped = !gap && prev.dataset.author === el.dataset.author
    const bubble = el.querySelector(".bubble")

    stamp.textContent = time.format(at)
    bubble.title = stamp.textContent
    el.classList.toggle("mine", mine)
    el.classList.toggle("stamp", gap)
    el.classList.toggle("cont", grouped)
    el.classList.toggle("jumbo", isJumbo(bubble.textContent))
    el.classList.add("tail") // only the last bubble of a group keeps its tail
    if (grouped) prev.classList.remove("tail")

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
