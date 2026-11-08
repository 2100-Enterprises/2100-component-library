import { Controller } from "@hotwired/stimulus"

// The text of an HTML string, close enough to count: tags dropped, each entity one character.
// Plain string work, so the HTML is never parsed into a DOM; only its length is used.
const ENTITY = /&(?:#\d+|#x[\da-f]+|[a-z][a-z\d]*);/gi
const NBSP = /^&(?:nbsp|#160|#xa0);$/i
function textOf(html) {
  return html.replace(/<[^>]*>/g, "").replace(ENTITY, (entity) => NBSP.test(entity) ? "\u00a0" : "_")
}

// A live character count for a field (FormFieldComponent `counter:`). Put on the field wrapper.
// The server already renders the rule in the hint; this adds the running count. The visible
// `count` updates on every input. The `status` live region (aria-live="polite") is updated only
// after typing pauses for `delay` ms, so a screen reader doesn't announce every keystroke. It
// never sets aria-invalid; that's for server errors.
//
// The `input` target is the control. With `html` true (rich text), the count is the text content
// of the HTML in the hidden input the control writes to: the target itself, or the element its
// `input` attribute names, as <trix-editor> has. Messages take %{count}.
export default class extends Controller {
  static targets = ["input", "count", "status"]
  static values = {
    min: Number, max: Number, html: Boolean,
    delay: { type: Number, default: 600 },
    leftMessage: String, overMessage: String, neededMessage: String
  }

  connect() {
    this.refresh()
    this.element.addEventListener("input", this.typed)
    this.element.addEventListener("trix-change", this.typed)
  }

  disconnect() {
    clearTimeout(this.timer)
    this.element.removeEventListener("input", this.typed)
    this.element.removeEventListener("trix-change", this.typed)
  }

  typed = () => {
    const message = this.refresh()

    clearTimeout(this.timer)
    this.timer = setTimeout(() => { if (this.hasStatusTarget) this.statusTarget.textContent = message }, this.delayValue)
  }

  // Updates the visible count and returns the message.
  refresh() {
    const message = this.message(this.length())

    if (this.hasCountTarget) this.countTarget.textContent = message
    return message
  }

  length() {
    const value = this.source?.value || ""
    if (!this.htmlValue) return value.length

    return textOf(value).trim().length
  }

  get source() {
    if (!this.hasInputTarget) return null

    const id = this.inputTarget.getAttribute("input")
    return id ? document.getElementById(id) : this.inputTarget
  }

  message(length) {
    if (this.hasMinValue && length < this.minValue) return this.format(this.neededMessageValue, "more character", this.minValue - length, "needed")
    if (!this.hasMaxValue) return ""

    const left = this.maxValue - length
    return left < 0 ? this.format(this.overMessageValue, "character", -left, "over") : this.format(this.leftMessageValue, "character", left, "left")
  }

  format(custom, noun, count, suffix) {
    if (custom) return custom.replace("%{count}", count.toLocaleString(document.documentElement.lang || undefined))

    const formatted = count.toLocaleString(document.documentElement.lang || undefined)
    return `${formatted} ${noun}${count === 1 ? "" : "s"} ${suffix}`
  }
}
