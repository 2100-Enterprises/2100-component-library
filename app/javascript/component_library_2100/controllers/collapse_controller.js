import { Controller } from "@hotwired/stimulus"

// Shows and hides a panel. State lives in attributes (`data-open` on the panel, `inert` on its
// inner wrapper, `aria-expanded` on triggers), so the classes in CollapseComponent do the animating.
// Dispatches `cl-collapse:opened` and `cl-collapse:closed` after the initial render.
export default class extends Controller {
  static targets = ["trigger", "panel", "inner"]
  static values = { open: Boolean }

  toggle() { this.openValue = !this.openValue }
  open() { this.openValue = true }
  close() { this.openValue = false }

  openValueChanged(open, previous) {
    this.panelTarget.toggleAttribute("data-open", open)
    this.innerTarget.inert = !open
    this.triggerTargets.forEach((trigger) => trigger.setAttribute("aria-expanded", open))

    if (previous !== undefined) this.dispatch(open ? "opened" : "closed")
  }
}
