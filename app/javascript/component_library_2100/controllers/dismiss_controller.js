import { Controller } from "@hotwired/stimulus"

// Removes its element when `close` is triggered (Alert, Toast, ...), or after `delay` milliseconds
// when `data-cl-dismiss-delay-value` is set. While closing it sets `data-closing`; give the element
// `transition-opacity data-closing:opacity-0` to fade. The fade is skipped under prefers-reduced-motion.
// Cancel with `event.preventDefault()` on `cl-dismiss:close`.
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    if (this.delayValue > 0) this.timer = setTimeout(() => this.close(), this.delayValue)
  }

  disconnect() { clearTimeout(this.timer) }

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
