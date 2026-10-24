import { Controller } from "@hotwired/stimulus"

const time = new Intl.DateTimeFormat(undefined, { hour: "2-digit", minute: "2-digit" }) // browser's time zone
const graphemes = new Intl.Segmenter()
// Only emoji (up to 3): rendered big, without a bubble.
const isJumbo = text => /\p{Extended_Pictographic}/u.test(text) &&
  !text.replace(/[\p{Extended_Pictographic}\p{Emoji_Modifier}‍️\s]/gu, "") &&
  [ ...graphemes.segment(text.replace(/\s/g, "")) ].length <= 3
// crypto.randomUUID needs https; plain http (phone on the LAN) falls back to getRandomValues.
const uuid = () => crypto.randomUUID?.() ??
  "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c => (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16))

let audio
// A soft, short "pop" for incoming messages. Synthesized: no audio file to download.
function chime() {
  if (audio?.state !== "running") return // browsers only allow sound after the person interacted
  const t = audio.currentTime
  const osc = audio.createOscillator()
  const gain = audio.createGain()
  osc.type = "sine"
  osc.frequency.setValueAtTime(660, t)
  osc.frequency.exponentialRampToValueAtTime(990, t + 0.09)
  gain.gain.setValueAtTime(0.0001, t)
  gain.gain.exponentialRampToValueAtTime(0.05, t + 0.015)
  gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.3)
  osc.connect(gain).connect(audio.destination)
  osc.start(t)
  osc.stop(t + 0.32)
}
function unlockAudio() {
  audio ||= new AudioContext()
  audio.resume().catch(() => {})
}

export default class extends Controller {
  static targets = [ "thread", "message", "notice", "draft", "form", "input", "error", "info", "link" ]
  static values = { me: String }

  connect() {
    unlockAudio() // works right away if the person already clicked on an earlier page (Turbo keeps the document)
    this.unlock = () => unlockAudio()
    addEventListener("pointerdown", this.unlock, { once: true })
    addEventListener("keydown", this.unlock, { once: true })
  }

  disconnect() {
    removeEventListener("pointerdown", this.unlock)
    removeEventListener("keydown", this.unlock)
  }

  // Messages arrive over the cable (ours too, replacing the optimistic copy). Style, stamp, then keep the view pinned.
  messageTargetConnected(el) {
    const mine = el.dataset.author === this.meValue
    const prev = el.previousElementSibling
    const stamp = el.querySelector("time")

    stamp.textContent = time.format(new Date(stamp.dateTime))
    el.classList.toggle("mine", mine)
    el.classList.toggle("cont", prev?.classList.contains("msg") && prev.dataset.author === el.dataset.author)
    el.classList.toggle("jumbo", isJumbo(el.querySelector(".text").textContent))

    this.follow(el, mine)
    if (!mine) chime()
  }

  noticeTargetConnected(el) {
    if (el.dataset.user === this.meValue) el.querySelector("span").textContent = "Você entrou"
    this.follow(el, false)
  }

  // Optimistic send: show it now (pending), post in the background. Several can be in flight at once.
  send(event) {
    event.preventDefault()
    const body = this.inputTarget.value.trim()
    if (!body) return

    const id = uuid()
    const draft = this.draftTarget.content.firstElementChild.cloneNode(true)
    draft.id = `message_${this.meValue}_${id}`
    draft.classList.add("pending")
    draft.querySelector(".text").textContent = body
    draft.querySelector("time").dateTime = new Date().toISOString()
    document.getElementById("messages").append(draft)

    this.formTarget.reset()
    this.inputTarget.focus()
    this.deliver(id, body)
  }

  // Tap a failed message to send it again.
  retry({ currentTarget: el }) {
    if (!el.classList.contains("failed")) return
    el.classList.replace("failed", "pending")
    this.deliver(el.id.split("_").pop(), el.querySelector(".text").textContent)
  }

  async deliver(id, body) {
    const data = new FormData()
    data.append("authenticity_token", this.formTarget.elements.authenticity_token.value)
    data.append("id", id)
    data.append("body", body)

    let status = 0
    try {
      status = (await fetch(this.formTarget.action, { method: "POST", body: data })).status
    } catch {} // offline: status stays 0

    // The broadcast usually lands first and already replaced the draft; this covers the rest.
    const el = document.getElementById(`message_${this.meValue}_${id}`)
    const ok = status >= 200 && status < 300
    if (el) {
      el.classList.remove("pending")
      el.classList.toggle("failed", !ok)
      el.querySelector(".status").ariaLabel = ok ? "Enviada" : "Não enviada"
      if (!ok) el.dataset.action = "click->room#retry"
    }
    this.errorTarget.hidden = ok
    if (!ok) this.errorTarget.textContent = status === 429 ? "Devagar! Espere alguns segundos." : "Não foi possível enviar."
  }

  follow(el, force) {
    const thread = this.threadTarget
    const nearBottom = thread.scrollHeight - thread.scrollTop - thread.clientHeight - el.offsetHeight < 120
    if (force || nearBottom) thread.scrollTo({ top: thread.scrollHeight, behavior: "smooth" })
  }

  openInfo() {
    this.infoTarget.showModal()
  }

  async copy({ currentTarget: button }) {
    const link = this.linkTarget
    try {
      await navigator.clipboard.writeText(link.value)
    } catch {
      // navigator.clipboard only exists on https/localhost; plain http (e.g. phone on the LAN) falls back.
      link.select()
      document.execCommand("copy")
      link.setSelectionRange(0, 0)
    }
    button.textContent = "Copiado"
    clearTimeout(this.copyTimer)
    this.copyTimer = setTimeout(() => (button.textContent = "Copiar link"), 3000)
  }
}
