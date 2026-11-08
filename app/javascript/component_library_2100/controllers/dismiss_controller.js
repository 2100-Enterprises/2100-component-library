import { Controller } from "@hotwired/stimulus"

// Removes its element when `close` is triggered (Alert, Toast, ...), or after `delay` milliseconds
// when `data-cl-dismiss-delay-value` is set. While closing it sets `data-closing`; give the element
// `transition-opacity data-closing:opacity-0` to fade. The fade is skipped under prefers-reduced-motion.
// Cancel with `event.preventDefault()` on `cl-dismiss:close`.
//
// With a delay, the countdown pauses while the pointer is over the element, while focus is inside it,
// and while the tab is hidden (WCAG 2.2.1), and resumes with the time that was left. Each reason is
// tracked on its own, so it resumes only when none is active. Without a delay nothing is timed or
// listened for. Events, none cancelable: `cl-dismiss:paused` and `cl-dismiss:resumed` when the
// countdown stops and restarts.
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    if (!(this.delayValue > 0)) return

    this.remaining = this.delayValue
    this.reasons = new Set()
    this.listeners = [
      [this.element, "mouseenter", () => this.hold("hover")],
      [this.element, "mouseleave", () => this.release("hover")],
      [this.element, "focusin", () => this.hold("focus")],
      [this.element, "focusout", (event) => { if (!this.element.contains(event.relatedTarget)) this.release("focus") }],
      [document, "visibilitychange", () => this[document.visibilityState === "hidden" ? "hold" : "release"]("hidden")]
    ]
    this.listeners.forEach(([target, type, handler]) => target.addEventListener(type, handler))

    if (document.visibilityState === "hidden") this.reasons.add("hidden")
    else this.start()
  }

  disconnect() {
    clearTimeout(this.timer)
    this.listeners?.forEach(([target, type, handler]) => target.removeEventListener(type, handler))
    this.listeners = null
  }

  start() {
    this.startedAt = Date.now()
    this.timer = setTimeout(() => this.close(), this.remaining)
  }

  hold(reason) {
    if (this.reasons.has(reason)) return
    const wasRunning = this.reasons.size === 0
    this.reasons.add(reason)
    if (!wasRunning) return

    clearTimeout(this.timer)
    this.remaining = Math.max(0, this.remaining - (Date.now() - this.startedAt))
    this.dispatch("paused", { bubbles: false })
  }

  release(reason) {
    if (!this.reasons.delete(reason) || this.reasons.size > 0) return

    this.start()
    this.dispatch("resumed", { bubbles: false })
  }

  close() {
    clearTimeout(this.timer)
    if (this.dispatch("close", { cancelable: true }).defaultPrevented) return

    let removed = false
    const remove = () => {
      if (removed) return
      removed = true
      this.element.remove()
      this.dispatch("closed", { bubbles: false })
    }

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return remove()

    this.element.addEventListener("transitionend", remove, { once: true })
    this.element.dataset.closing = ""
    setTimeout(remove, 300) // fallback if no transition runs
  }
}
