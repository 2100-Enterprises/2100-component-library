import { Controller } from "@hotwired/stimulus"

// The styled confirm dialog (ConfirmDialogComponent). It opens on a `cl-confirm:open` window
// event, whose detail is { message, title, accept, resolve }, and calls resolve(true) when the
// person confirms or resolve(false) when they cancel, press Escape or click the backdrop.
// `confirmMethod` in index.js sends that event; `useStyledConfirm(Turbo)` hands it to Turbo.
export default class extends Controller {
  static targets = ["dialog", "title", "message", "accept"]
  static values = { title: String, accept: String }

  #resolve = null

  open({ detail }) {
    // A second request while open answers the first with false and reuses the open dialog.
    const previous = this.#resolve
    this.#resolve = null
    previous?.(false)

    this.messageTarget.textContent = detail.message ?? ""
    this.titleTarget.textContent = detail.title || this.titleValue
    this.acceptTarget.textContent = detail.accept || this.acceptValue
    this.#resolve = detail.resolve
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
  }

  accept() { this.#settle(true) }

  // Also wired to the dialog's `close` event, which fires however it closes.
  cancel() { this.#settle(false) }

  disconnect() { this.#settle(false) }

  #settle(answer) {
    const resolve = this.#resolve
    this.#resolve = null
    if (this.dialogTarget.open) this.dialogTarget.close()
    resolve?.(answer)
  }
}
