import { Controller } from "@hotwired/stimulus"

// Submits the element's form when it changes (SwitchComponent `autosubmit: true`, FormBuilder `autosubmit:`).
// requestSubmit() runs validation and the form's submit handlers, so Turbo handles it.
//
// `delay` (ms, default 0) debounces: each call restarts the timer, so a search box wired with
// `data-action="input->cl-autosubmit#submit"` submits once typing pauses. A pending submit is
// dropped when the form is submitted some other way (Enter, a button) and on disconnect.
export default class extends Controller {
  static values = { delay: { type: Number, default: 0 } }

  connect() {
    this.form = this.element.form
    this.cancel = this.cancel.bind(this)
    this.form?.addEventListener("submit", this.cancel)
  }

  disconnect() {
    this.cancel()
    this.form?.removeEventListener("submit", this.cancel)
  }

  submit() {
    this.cancel()
    if (this.delayValue > 0) {
      this.timer = setTimeout(() => this.send(), this.delayValue)
    } else {
      this.send()
    }
  }

  send() {
    this.timer = null
    this.element.form?.requestSubmit()
  }

  cancel() {
    clearTimeout(this.timer)
    this.timer = null
  }
}
