import { Controller } from "@hotwired/stimulus"

// Opens and closes a native <dialog> as a modal (Modal, Offcanvas). The browser provides the
// backdrop, focus trap, inert page, Escape to close and focus return.
// `locked` ignores clicks on the backdrop. Optional `trigger` targets get aria-expanded kept in
// step with the dialog (the dialog's own `close` event covers Escape and form submits).
export default class extends Controller {
  static targets = ["dialog", "trigger"]
  static values = { locked: Boolean }

  open() {
    this.dialogTarget.showModal()
    this.#expand(true)
  }

  close() { this.dialogTarget.close() }

  connect() {
    this.closed = () => this.#expand(false)
    this.dialogTarget.addEventListener("close", this.closed)
  }

  backdrop(event) {
    if (event.target === this.dialogTarget && !this.lockedValue) this.close()
  }

  // Keeps a Turbo page snapshot from restoring an open modal.
  disconnect() {
    this.dialogTarget.close()
    this.dialogTarget.removeEventListener("close", this.closed)
  }

  #expand(open) {
    this.triggerTargets.forEach((trigger) => trigger.setAttribute("aria-expanded", open))
  }
}
