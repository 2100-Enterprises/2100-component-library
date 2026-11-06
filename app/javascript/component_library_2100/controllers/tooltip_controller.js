import { Controller } from "@hotwired/stimulus"
import { place } from "component_library_2100/position"

// Shows a `popover="manual"` tooltip on hover and keyboard focus, hides it on leave, blur and Escape.
// The controller element is the anchor; its first child gets `aria-describedby`.
export default class extends Controller {
  static targets = ["tip"]
  static values = {
    placement: { type: String, default: "top" },
    offset: { type: Number, default: 6 }
  }

  connect() {
    this.element.firstElementChild?.setAttribute("aria-describedby", this.tipTarget.id)
  }

  disconnect() { this.hide() }

  show() {
    if (this.tipTarget.matches(":popover-open")) return

    this.tipTarget.showPopover()
    place(this.element, this.tipTarget, { placement: this.placementValue, offset: this.offsetValue })
    this.tipTarget.dataset.positioned = ""
  }

  hide() {
    if (!this.tipTarget.matches(":popover-open")) return

    this.tipTarget.hidePopover()
    delete this.tipTarget.dataset.positioned
  }
}
