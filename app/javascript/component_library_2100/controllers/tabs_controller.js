import { Controller } from "@hotwired/stimulus"

// Tabs following the WAI-ARIA tabs pattern: click or arrow keys select, Home/End jump,
// only the selected tab is in the tab order. Tabs and panels pair up by position.
export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    this.#show(this.tabTargets.indexOf(event.currentTarget))
  }

  navigate(event) {
    const tabs = this.tabTargets.filter((tab) => !tab.disabled)
    const index = tabs.indexOf(document.activeElement)
    if (index < 0) return

    const next = {
      ArrowRight: tabs[(index + 1) % tabs.length],
      ArrowLeft: tabs[(index - 1 + tabs.length) % tabs.length],
      Home: tabs[0],
      End: tabs.at(-1)
    }[event.key]

    if (!next) return
    event.preventDefault()
    next.focus()
    this.#show(this.tabTargets.indexOf(next))
  }

  #show(index) {
    this.tabTargets.forEach((tab, i) => {
      const selected = i === index
      tab.setAttribute("aria-selected", selected)
      tab.tabIndex = selected ? 0 : -1
      this.panelTargets[i].hidden = !selected
    })
  }
}
