import { Controller } from "@hotwired/stimulus"

// Submits the element's form when it changes (SwitchComponent `autosubmit: true`).
// requestSubmit() runs validation and the form's submit handlers, so Turbo handles it.
export default class extends Controller {
  submit() { this.element.form?.requestSubmit() }
}
