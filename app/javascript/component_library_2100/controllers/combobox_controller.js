import { Controller } from "@hotwired/stimulus"

const OPTION = '[role="option"]:not([aria-disabled="true"]):not([hidden])'

// A combobox with server-side suggestions (ComboboxComponent), after the WAI-ARIA 1.2 pattern.
// Typing sets the `src` of the Turbo Frame in the listbox to `src?q=<text>` after a debounce. DOM
// focus stays in the input; `aria-activedescendant` names the active option, which also carries
// `aria-selected="true"`. Dispatches `cl-combobox:select` with { value, label }.
//
// The input is named for the form in the markup, so it submits as plain text without JavaScript.
// On connect the name moves to the hidden input, which then holds the value.
//
// With `multiple` (tags mode) the values are chips and hidden inputs inside the "values" target,
// there is no single hidden input, and the visible input only ever holds the text being typed. Static
// `options` (no `src`) are filtered in the browser instead of loaded.
export default class extends Controller {
  static targets = ["input", "hidden", "listbox", "frame", "status", "indicator", "values", "chips", "chip", "template", "limit"]
  static values = {
    src: String,
    minLength: { type: Number, default: 1 },
    delay: { type: Number, default: 250 },
    forceSelection: Boolean,
    multiple: Boolean,
    max: Number,
    allowFreeText: Boolean,
    addedMessage: { type: String, default: "%{value} added" },
    removedMessage: { type: String, default: "%{value} removed" },
    maxMessage: { type: String, default: "Maximum of %{max} reached" },
    noneMessage: { type: String, default: "No results" },
    oneMessage: { type: String, default: "1 result" },
    manyMessage: { type: String, default: "%{count} results" }
  }

  connect() {
    this.active = null
    this.moveOnLoad = null
    if (this.multipleValue) {
      this.#syncLimit()
      this.#hideChosen()
      return
    }

    if (this.inputTarget.name && !this.hiddenTarget.name) {
      this.hiddenTarget.name = this.inputTarget.name
      this.inputTarget.removeAttribute("name")
    }
    this.selected = { value: this.hiddenTarget.value, label: this.inputTarget.value }
  }

  disconnect() { clearTimeout(this.timer) }

  // The input changed: the text is the value unless a selection is forced, and a search is queued.
  input() {
    const text = this.inputTarget.value

    if (!this.multipleValue) {
      if (!this.forceSelectionValue) this.hiddenTarget.value = text
      else this.hiddenTarget.value = text === this.selected.label ? this.selected.value : ""
    }
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
        } else if (this.multipleValue && this.inputTarget.value.trim() !== "") {
          event.preventDefault()
          this.#commitText()
        } else {
          this.#close()
        }
        break
      case ",":
        if (this.multipleValue && this.allowFreeTextValue) {
          event.preventDefault()
          this.#commitText()
        }
        break
      case "Backspace":
        if (this.multipleValue && this.inputTarget.value === "" && this.chosen.length > 0) {
          event.preventDefault()
          this.#removeChip(this.chipTargets[this.chipTargets.length - 1])
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

  // Wired to each chip's remove button (multiple).
  remove(event) {
    this.#removeChip(event.currentTarget.closest('[data-cl-combobox-target~="chip"]'))
  }

  blur() {
    clearTimeout(this.timer)
    this.#close()
    if (!this.multipleValue && this.forceSelectionValue && this.hiddenTarget.value === "") this.inputTarget.value = ""
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
    this.#hideChosen()
    this.#present()
  }

  failed() { this.#idle() }

  // Announces the result count and opens the list when there's something to choose.
  #present() {
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

  // Static options: show those whose label contains the text, minus the chosen ones.
  #filterStatic() {
    this.#refreshStatic()
    this.#present()
  }

  #refreshStatic() {
    const query = this.inputTarget.value.trim().toLowerCase()
    const chosen = this.multipleValue ? this.chosen : []
    this.listboxTarget.querySelectorAll('[role="option"]').forEach(option => {
      const label = (option.dataset.label ?? option.textContent).toLowerCase()
      option.hidden = chosen.includes(option.dataset.value) || !label.includes(query)
    })
  }

  // Chosen values aren't suggested again.
  #hideChosen() {
    if (!this.multipleValue) return
    if (!this.srcValue) return this.#refreshStatic()

    const chosen = this.chosen
    this.listboxTarget.querySelectorAll('[role="option"]').forEach(option => {
      option.hidden = chosen.includes(option.dataset.value)
    })
  }

  #search() {
    if (!this.srcValue) return this.#filterStatic()

    const url = new URL(this.srcValue, window.location.href)
    url.searchParams.set("q", this.inputTarget.value)

    if (this.frameTarget.src === url.href) this.frameTarget.reload()
    else this.frameTarget.src = url.href
  }

  // Opens the list, or searches first when there's nothing to show. `move` is "first" or null.
  #show(move) {
    if (!this.srcValue && this.inputTarget.value.length >= this.minLengthValue) {
      this.#filterStatic()
    } else if (this.#options.length > 0 && this.frameTarget.src) {
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

    if (this.multipleValue) return this.#addChip(value, label)

    this.selected = { value, label }
    this.hiddenTarget.value = value
    this.inputTarget.value = label
    this.#close()
    this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.dispatch("select", { detail: { value, label } })
  }

  // Enter or comma: the typed text becomes a chip (free text), or is dropped.
  #commitText() {
    const text = this.inputTarget.value.trim().replace(/,/g, "")
    if (text === "") return

    if (this.allowFreeTextValue) this.#addChip(text, text)
    else this.#close()
  }

  get chosen() { return this.chipTargets.map(chip => chip.dataset.value) }
  get #full() { return this.hasMaxValue && this.chosen.length >= this.maxValue }

  #addChip(value, label) {
    this.inputTarget.value = ""
    this.#close()
    if (this.chosen.includes(value) || this.#full) return

    const chip = this.templateTarget.content.firstElementChild.cloneNode(true)
    chip.dataset.value = value
    chip.firstElementChild.textContent = label
    const button = chip.querySelector("button")
    button.setAttribute("aria-label", `Remove ${label}`)
    this.chipsTarget.appendChild(chip)

    const field = document.createElement("input")
    field.type = "hidden"
    field.name = this.valuesTarget.firstElementChild.name
    field.value = value
    field.autocomplete = "off"
    this.valuesTarget.appendChild(field)

    this.#syncLimit()
    this.#changed(this.addedMessageValue.replace("%{value}", label))
    // The input is hidden at the limit, so keep focus on something that can still act.
    if (this.#full) button.focus()
    this.dispatch("select", { detail: { value, label } })
  }

  // Removing returns focus to the input.
  #removeChip(chip) {
    if (!chip) return
    const value = chip.dataset.value
    const label = chip.firstElementChild.textContent
    chip.remove()
    this.valuesTarget.querySelectorAll("input").forEach(field => { if (field.value === value) field.remove() })

    this.#syncLimit()
    this.#changed(this.removedMessageValue.replace("%{value}", label))
    this.inputTarget.focus()
  }

  // Shows or hides the input and the limit message to match the number of chips.
  #syncLimit() {
    const full = this.#full
    this.inputTarget.hidden = full
    this.limitTarget.textContent = full ? this.maxMessageValue.replace("%{max}", this.maxValue) : ""
  }

  #changed(message) {
    this.statusTarget.textContent = message
    this.#hideChosen()
    this.valuesTarget.firstElementChild.dispatchEvent(new Event("change", { bubbles: true }))
  }

  #clear() {
    if (this.multipleValue) {
      this.inputTarget.value = ""
      return this.#close()
    }

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
