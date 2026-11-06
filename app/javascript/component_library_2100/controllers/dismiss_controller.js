import { Controller } from "@hotwired/stimulus"

// Removes its element when `close` is triggered (Alert, Toast, ...).
// The element should carry `transition-opacity`; the fade is skipped under
// prefers-reduced-motion. Cancel with `event.preventDefault()` on `cl-dismiss:close`.
export default class extends Controller {
  close() {
    if (this.dispatch("close", { cancelable: true }).defaultPrevented) return

    const remove = () => {
      this.element.remove()
      this.dispatch("closed", { bubbles: false })
    }

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return remove()

    this.element.addEventListener("transitionend", remove, { once: true })
    this.element.classList.add("opacity-0")
    setTimeout(remove, 300) // fallback if no transition runs
  }
}
