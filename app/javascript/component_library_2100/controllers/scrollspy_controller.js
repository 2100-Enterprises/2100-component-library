import { Controller } from "@hotwired/stimulus"

// Scrollspy: marks the nav link whose target section is in view with aria-current="true", using an
// IntersectionObserver. Clicking a link smooth-scrolls to its section, allowing for an offset.
export default class extends Controller {
  static targets = ["link"]
  static values = {
    offset: { type: Number, default: 0 },
    smooth: { type: Boolean, default: true }
  }

  connect() {
    this.sections = this.linkTargets
      .map((link) => this.#targetFor(link))
      .filter(Boolean)

    this.observer = new IntersectionObserver((entries) => this.#onIntersect(entries), {
      rootMargin: `${-this.offsetValue}px 0px -60% 0px`,
      threshold: 0
    })
    this.sections.forEach((section) => this.observer.observe(section))
  }

  disconnect() {
    this.observer?.disconnect()
  }

  click(event) {
    const section = this.#targetFor(event.currentTarget)
    if (!section) return
    if (this.smoothValue) {
      event.preventDefault()
      const top = section.getBoundingClientRect().top + window.scrollY - this.offsetValue
      window.scrollTo({ top, behavior: "smooth" })
    }
    this.#activate(event.currentTarget)
  }

  // --- private ---

  #onIntersect(entries) {
    const visible = entries.filter((e) => e.isIntersecting)
    if (visible.length === 0) return
    const top = visible.sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)[0]
    const link = this.#linkFor(top.target)
    if (link) this.#activate(link)
  }

  #activate(current) {
    this.linkTargets.forEach((link) => {
      if (link === current) link.setAttribute("aria-current", "true")
      else link.removeAttribute("aria-current")
    })
  }

  #targetFor(link) {
    const hash = link.getAttribute("href") || ""
    const id = hash.startsWith("#") ? hash.slice(1) : null
    return id ? document.getElementById(id) : null
  }

  #linkFor(section) {
    return this.linkTargets.find((link) => this.#targetFor(link) === section)
  }
}
