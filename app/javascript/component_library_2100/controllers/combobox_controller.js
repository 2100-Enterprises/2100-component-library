import { Controller } from "@hotwired/stimulus"

const OPTION = '[role="option"]:not([aria-disabled="true"])'

// A combobox with server-side suggestions (ComboboxComponent), after the WAI-ARIA 1.2 pattern.
// Typing sets the `src` of the Turbo Frame in the listbox to `src?q=<text>` after a debounce. DOM
// focus stays in the input; `aria-activedescendant` names the active option, which also carries
// `aria-selected="true"`. Dispatches `cl-combobox:select` with { value, label }.
//
// The input is named for the form in the markup, so it submits as plain text without JavaScript.
// On connect the name moves to the hidden input, which then holds the value.
export default class extends Controller {
  static targets = ["input", "hidden", "listbox", "frame", "status", "indicator"]
  static values = {
    src: String,
    minLength: { type: Number, default: 1 },
    delay: { type: Number, default: 250 },
    forceSelection: Boolean,
    noneMessage: { type: String, default: "No results" },
    oneMessage: { type: String, default: "1 result" },
    manyMessage: { type: String, default: "%{count} results" }
  }

  connect() {
    if (this.inputTarget.name && !this.hiddenTarget.name) {
      this.hiddenTarget.name = this.inputTarget.name
      this.inputTarget.removeAttribute("name")
    }
    this.selected = { value: this.hiddenTarget.value, label: this.inputTarget.value }
    this.active = null
    this.moveOnLoad = null
  }

  disconnect() { clearTimeout(this.timer) }

  // The input changed: the text is the value unless a selection is forced, and a search is queued.
  input() {
    const text = this.inputTarget.value

    if (!this.forceSelectionValue) this.hiddenTarget.value = text
    else this.hiddenTarget.value = text === this.selected.label ? this.selected.value : ""
    clearTimeout(this.timer)
    this.moveOnLoad = null

    if (text.length < this.minLengthValue) return this.#close()
    this.timer = setTimeout(() => this.#search(), this.delayValue)
  }

  keydown(event) {
    if (event.isComposing) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (event.altKey) this.#show(null)
        else if (this.#isOpen) this.#move(1)
        else this.#show("first")
        break
      case "ArrowUp":
        if (event.altKey) {
          event.preventDefault()
          this.active ? this.#select(this.active) : this.#close()
        } else if (this.#isOpen) {
          event.preventDefault()
          this.#move(-1)
        }
        break
      case "Enter":
        if (this.#isOpen && this.active) {
          event.preventDefault()
          this.#select(this.active)
        } else {
          this.#close()
        }
        break
      case "Escape":
        if (this.#isOpen) {
          event.preventDefault()
          event.stopPropagation()
          this.#close()
        } else if (this.inputTarget.value) {
          event.preventDefault()
          event.stopPropagation()
          this.#clear()
        }
        break
      case "Tab":
        this.#close()
        break
    }
  }

  blur() {
    clearTimeout(this.timer)
    this.#close()
    if (this.forceSelectionValue && this.hiddenTarget.value === "") this.inputTarget.value = ""
  }

  // Wired to the listbox. Pressing an option mustn't blur the input.
  hold(event) { event.preventDefault() }

  choose(event) {
    const option = event.target.closest(OPTION)
    if (option) this.#select(option)
  }

  hover(event) {
    const option = event.target.closest(OPTION)
    if (option && option !== this.active) this.#activate(option, { scroll: false })
  }

  // Wired to the frame's Turbo events.
  loading(event) {
    if (event.target !== this.frameTarget) return
    this.listboxTarget.setAttribute("aria-busy", "true")
    this.indicatorTarget.hidden = false
  }

  loaded(event) {
    if (event.target !== this.frameTarget) return
    this.#idle()

    const count = this.#options.length
    const move = this.moveOnLoad
    this.moveOnLoad = null
    this.#deactivate()
    this.#announce(count)

    if (count > 0 && document.activeElement === this.inputTarget && this.inputTarget.value.length >= this.minLengthValue) {
      this.#open()
      if (move) this.#move(1)
    } else {
      this.#close()
    }
  }

  failed() { this.#idle() }

  #search() {
    const url = new URL(this.srcValue, window.location.href)
    url.searchParams.set("q", this.inputTarget.value)

    if (this.frameTarget.src === url.href) this.frameTarget.reload()
    else this.frameTarget.src = url.href
  }

  // Opens the list, or searches first when there's nothing to show. `move` is "first" or null.
  #show(move) {
    if (this.#options.length > 0 && this.frameTarget.src) {
      this.#open()
      if (move) this.#move(1)
    } else if (this.inputTarget.value.length >= this.minLengthValue) {
      clearTimeout(this.timer)
      this.moveOnLoad = move
      this.#search()
    }
  }

  #move(step) {
    const options = this.#options
    if (options.length === 0) return

    const index = options.indexOf(this.active)
    const next = step > 0 ? options[Math.min(index + 1, options.length - 1)] : options[index < 0 ? options.length - 1 : Math.max(index - 1, 0)]
    this.#activate(next)
  }

  #activate(option, { scroll = true } = {}) {
    this.#deactivate()
    this.active = option
    option.setAttribute("aria-selected", "true")
    this.inputTarget.setAttribute("aria-activedescendant", option.id)
    if (scroll) option.scrollIntoView({ block: "nearest" })
  }

  #deactivate() {
    this.active?.setAttribute("aria-selected", "false")
    this.active = null
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  #select(option) {
    const value = option.dataset.value
    const label = option.dataset.label ?? option.textContent.trim()

    this.selected = { value, label }
    this.hiddenTarget.value = value
    this.inputTarget.value = label
    this.#close()
    this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.dispatch("select", { detail: { value, label } })
  }

  #clear() {
    this.selected = { value: "", label: "" }
    this.inputTarget.value = ""
    this.hiddenTarget.value = ""
    this.#close()
  }

  #open() {
    this.listboxTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  #close() {
    this.listboxTarget.hidden = true
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.#deactivate()
  }

  #idle() {
    this.listboxTarget.setAttribute("aria-busy", "false")
    this.indicatorTarget.hidden = true
  }

  #announce(count) {
    const message = count === 0 ? this.noneMessageValue : count === 1 ? this.oneMessageValue : this.manyMessageValue
    this.statusTarget.textContent = message.replace("%{count}", count)
  }

  get #isOpen() { return !this.listboxTarget.hidden }
  get #options() { return [...this.listboxTarget.querySelectorAll(OPTION)] }
}
