import { Controller } from "@hotwired/stimulus"
import { place } from "component_library_2100/position"

const MENU_ITEMS = '[role="menuitem"]:not(:disabled):not([aria-disabled="true"])'

// Positions a native popover (`popover="auto"`) next to its trigger. The browser handles opening,
// light dismiss, Escape and focus return; this adds placement, `aria-expanded`, and arrow-key
// navigation when the panel holds menu items (Dropdown).
export default class extends Controller {
  static targets = ["trigger", "panel"]
  static values = {
    placement: { type: String, default: "bottom" },
    offset: { type: Number, default: 4 }
  }

  disconnect() { this.#listen(false) }

  // Wired to the panel's `toggle` event.
  sync(event) {
    const open = event.newState === "open"

    this.triggerTargets.forEach((trigger) => trigger.setAttribute("aria-expanded", open))
    this.#listen(open)

    if (open) {
      this.reposition()
      this.#items[0]?.focus()
    } else {
      delete this.panelTarget.dataset.positioned
    }
  }

  reposition = () => {
    place(this.triggerTarget, this.panelTarget, { placement: this.placementValue, offset: this.offsetValue })
    this.panelTarget.dataset.positioned = ""
  }

  close() {
    if (this.panelTarget.matches(":popover-open")) this.panelTarget.hidePopover()
  }

  navigate(event) {
    if (event.key === "Tab") return this.close()

    const items = this.#items
    if (items.length === 0) return

    const index = items.indexOf(document.activeElement)
    const next = {
      ArrowDown: items[index + 1] ?? items[0],
      ArrowUp: index > 0 ? items[index - 1] : items.at(-1),
      Home: items[0],
      End: items.at(-1)
    }[event.key]

    if (!next) return
    event.preventDefault()
    next.focus()
  }

  get #items() {
    return [...this.panelTarget.querySelectorAll(MENU_ITEMS)]
  }

  #listen(on) {
    const method = on ? "addEventListener" : "removeEventListener"
    window[method]("resize", this.reposition)
    window[method]("scroll", this.reposition, true)
  }
}
