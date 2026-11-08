import { Controller } from "@hotwired/stimulus"

// Progressive enhancement for FileUploadComponent. The native file input works without this; the
// controller lists the chosen files (name, size, "Remove <name>"), flags a file that is too large or
// not an accepted type, accepts drops on the optional dropzone, and announces changes in the polite
// live region. The server checks size and type again. A flagged file is kept, never dropped silently.
//
// With Active Storage direct uploads, the `direct-upload:*` events (bubbling from the input) drive the
// progress bar.
export default class extends Controller {
  static targets = ["input", "zone", "list", "template", "status", "progress"]
  static values = { maxBytes: Number, maxLabel: String }

  connect() {
    this.baseDescribedby = this.inputTarget.getAttribute("aria-describedby") || ""
    this.uploads = new Map()
    this.element.dataset.enhanced = ""
    this.render({ announce: false })
  }

  disconnect() {
    delete this.element.dataset.enhanced
  }

  render({ announce = true } = {}) {
    const files = Array.from(this.inputTarget.files)
    const problems = files.map((file) => this.#problem(file))

    this.#resetUploads()
    this.listTarget.replaceChildren(...files.map((file, index) => this.#row(file, index, problems[index])))
    this.listTarget.hidden = files.length === 0
    this.#describe(problems)

    if (announce) this.#announce(files, problems)
  }

  remove(event) {
    const index = Number(event.currentTarget.closest("li").dataset.index)
    const files = Array.from(this.inputTarget.files)
    const [removed] = files.splice(index, 1)
    this.#setFiles(files)
    this.render({ announce: false })

    const remaining = files.length ? `${files.length} ${files.length === 1 ? "file" : "files"} remaining.` : "No file chosen."
    this.#say(`Removed ${removed.name}. ${remaining}`)
    const next = this.listTarget.querySelectorAll("[data-remove]")[Math.min(index, files.length - 1)]
    ;(next || this.inputTarget).focus()
  }

  dragover(event) {
    if (!this.#hasFiles(event)) return
    event.preventDefault()
    this.zoneTarget.dataset.dragging = ""
  }

  dragleave(event) {
    if (!this.zoneTarget.contains(event.relatedTarget)) delete this.zoneTarget.dataset.dragging
  }

  drop(event) {
    if (!this.#hasFiles(event)) return
    event.preventDefault()
    delete this.zoneTarget.dataset.dragging

    const dropped = Array.from(event.dataTransfer.files)
    const files = this.inputTarget.multiple ? dropped : dropped.slice(0, 1)
    this.#setFiles(files)
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    if (dropped.length > files.length) this.#say(`${this.statusTarget.textContent} Only one file can be uploaded, so ${files[0].name} was used.`)
  }

  uploadStart({ detail: { id } }) {
    this.uploads.set(id, 0)
    this.progressTarget.hidden = false
    this.#paint()
  }

  uploadProgress({ detail: { id, progress } }) {
    this.uploads.set(id, progress)
    this.#paint()
  }

  uploadEnd({ detail: { id } }) {
    this.uploads.set(id, 100)
    this.#paint()
  }

  uploadError({ detail: { file } }) {
    this.progressTarget.hidden = true
    this.#say(`Upload of ${file.name} failed.`)
  }

  #paint() {
    const values = [...this.uploads.values()]
    const percent = Math.round(values.reduce((sum, value) => sum + value, 0) / values.length)
    const bar = this.progressTarget.querySelector("[role=progressbar]")
    bar.setAttribute("aria-valuenow", percent)
    bar.style.width = `${percent}%`
    bar.textContent = `${percent}%`
  }

  #resetUploads() {
    this.uploads.clear()
    this.progressTarget.hidden = true
  }

  #row(file, index, problem) {
    const row = this.templateTarget.content.firstElementChild.cloneNode(true)
    row.dataset.index = index
    row.querySelector("[data-name]").textContent = file.name
    row.querySelector("[data-size]").textContent = this.#humanSize(file.size)
    row.querySelector("[data-remove]").setAttribute("aria-label", `Remove ${file.name}`)

    const warning = row.querySelector("[data-warning]")
    warning.id = `${this.inputTarget.id}-warning-${index}`
    warning.textContent = problem || ""
    warning.hidden = !problem
    return row
  }

  // Warnings join the input's description, so a screen reader reads them with the field.
  #describe(problems) {
    const ids = [...this.listTarget.querySelectorAll("[data-warning]")].filter((_, index) => problems[index]).map((warning) => warning.id)
    const value = [this.baseDescribedby, ...ids].filter(Boolean).join(" ")
    if (value) this.inputTarget.setAttribute("aria-describedby", value)
    else this.inputTarget.removeAttribute("aria-describedby")
  }

  #announce(files, problems) {
    if (files.length === 0) return this.#say("No file chosen.")

    const flagged = files.flatMap((file, index) => (problems[index] ? [`${file.name}: ${problems[index]}`] : []))
    if (flagged.length) return this.#say(flagged.join(" "))
    this.#say(files.length === 1 ? `${files[0].name} is ready to upload.` : `${files.length} files ready to upload`)
  }

  #say(message) {
    this.statusTarget.textContent = message
  }

  // input.files is read-only, so a changed list goes in through a DataTransfer.
  #setFiles(files) {
    const transfer = new DataTransfer()
    files.forEach((file) => transfer.items.add(file))
    this.inputTarget.files = transfer.files
  }

  #hasFiles(event) {
    return Array.from(event.dataTransfer?.types || []).includes("Files")
  }

  #problem(file) {
    if (this.hasMaxBytesValue && this.maxBytesValue > 0 && file.size > this.maxBytesValue) {
      return `This file is larger than ${this.maxLabelValue}. Choose a smaller one.`
    }

    const allowed = (this.inputTarget.accept || "").split(",").map((token) => token.trim().toLowerCase()).filter(Boolean)
    if (allowed.length && !allowed.some((token) => this.#accepts(token, file))) return "This kind of file can't be uploaded."
    return null
  }

  #accepts(token, file) {
    if (token.startsWith(".")) return file.name.toLowerCase().endsWith(token)
    if (token.endsWith("/*")) return file.type.toLowerCase().startsWith(token.slice(0, -1))
    return file.type.toLowerCase() === token
  }

  #humanSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }
}
