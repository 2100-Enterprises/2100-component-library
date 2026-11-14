import { Controller } from "@hotwired/stimulus"

// Bulk selection for a list or table (BulkActionBarComponent, `ui_selection_checkbox`).
// Put `data-controller="cl-bulk-select"` on a container holding the row checkboxes (target
// `item`), an optional select-all checkbox (`all`, indeterminate when only some rows are
// checked) and the action bar (`bar`, shown only while something is selected). `count` shows
// the number selected and `status` is a polite live region that announces "N selected".
// `data-cl-bulk-select-count-value` always holds the number selected.
// Rows added or replaced by Turbo are picked up through the target callbacks.
export default class extends Controller {
  static targets = ["item", "all", "bar", "count", "status"]
  static values = { count: { type: Number, default: 0 } }

  #announced = null

  itemTargetConnected() { this.update() }
  itemTargetDisconnected() { this.update() }
  allTargetConnected() { this.update() }
  barTargetConnected() { this.update() }
  countTargetConnected() { this.update() }

  toggleAll(event) {
    const checked = event?.target?.checked ?? !this.#allChecked
    this.#enabledItems.forEach((item) => { item.checked = checked })
    this.update()
  }

  clear() {
    this.itemTargets.forEach((item) => { item.checked = false })
    this.update()
  }

  update() {
    const items = this.#enabledItems
    const selected = items.filter((item) => item.checked).length
    this.countValue = selected

    this.allTargets.forEach((all) => {
      all.checked = items.length > 0 && selected === items.length
      all.indeterminate = selected > 0 && selected < items.length
    })
    this.barTargets.forEach((bar) => { bar.hidden = selected === 0 })
    this.countTargets.forEach((count) => { count.textContent = this.#label(count, selected) })

    if (selected !== this.#announced) {
      // Don't announce the initial state of a page with nothing selected.
      if (this.#announced !== null || selected > 0) {
        this.statusTargets.forEach((status) => { status.textContent = selected > 0 ? `${this.#label(this.hasCountTarget ? this.countTarget : null, selected)} selected` : "" })
      }
      this.#announced = selected
    }
  }

  // "3", or "3 posts" when the count element has data-noun and data-noun-plural.
  #label(element, n) {
    const noun = n === 1 ? element?.dataset.noun : element?.dataset.nounPlural
    return noun ? `${n} ${noun}` : String(n)
  }

  get #enabledItems() { return this.itemTargets.filter((item) => !item.disabled) }
  get #allChecked() { return this.#enabledItems.length > 0 && this.#enabledItems.every((item) => item.checked) }
}
