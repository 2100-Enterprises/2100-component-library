import { Controller } from "@hotwired/stimulus"

// Shows or hides a password field's text (FormBuilder#password_field). The button's visible
// label swaps between the `show` and `hide` values; a visually hidden " password" follows it.
export default class extends Controller {
  static targets = ["input", "label"]
  static values = { show: { type: String, default: "Show" }, hide: { type: String, default: "Hide" } }

  toggle() {
    const hidden = this.inputTarget.type === "password"

    this.inputTarget.type = hidden ? "text" : "password"
    if (this.hasLabelTarget) this.labelTarget.textContent = hidden ? this.hideValue : this.showValue
  }

  // Never leave a password readable in a Turbo snapshot.
  disconnect() { this.inputTarget.type = "password" }
}
