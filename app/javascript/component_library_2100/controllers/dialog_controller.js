import { Controller } from "@hotwired/stimulus"

// Opens and closes a native <dialog> as a modal (Modal, Offcanvas). The browser provides the
// backdrop, focus trap, inert page, Escape to close and focus return.
// `locked` ignores clicks on the backdrop.
export default class extends Controller {
  static targets = ["dialog"]
  static values = { locked: Boolean }

  open() { this.dialogTarget.showModal() }
  close() { this.dialogTarget.close() }

  backdrop(event) {
    if (event.target === this.dialogTarget && !this.lockedValue) this.close()
  }

  // Keeps a Turbo page snapshot from restoring an open modal.
  disconnect() { this.dialogTarget.close() }
}
