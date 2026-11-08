import { Controller } from "@hotwired/stimulus"

// Bootstrap-style carousel: previous/next controls, indicator dots, keyboard (arrow keys), swipe,
// and autoplay with pause-on-hover and pause-when-tab-hidden. Slides pair with indicators by order.
export default class extends Controller {
  static targets = ["slide", "indicator", "prev", "next"]
  static values = {
    index: { type: Number, default: 0 },
    interval: { type: Number, default: 5000 },
    wrap: { type: Boolean, default: true },
    keyboard: { type: Boolean, default: true },
    pause: { type: String, default: "hover" },
    ride: { type: Boolean, default: false },
    touch: { type: Boolean, default: true },
    crossfade: { type: Boolean, default: false }
  }

  connect() {
    this.indexValue = Math.max(0, this.slideTargets.findIndex((s) => s.hasAttribute("data-active")))
    if (this.indexValue < 0) this.indexValue = 0
    this.#render()

    this.onVisibility = () => (document.hidden ? this.#stop() : this.#maybeStart())
    document.addEventListener("visibilitychange", this.onVisibility)
    if (this.touchValue) this.#bindSwipe()
    this.#maybeStart()
  }

  disconnect() {
    this.#stop()
    document.removeEventListener("visibilitychange", this.onVisibility)
  }

  next() {
    const last = this.slideTargets.length - 1
    if (!this.wrapValue && this.indexValue >= last) return
    this.#show((this.indexValue + 1) % this.slideTargets.length)
  }

  prev() {
    const length = this.slideTargets.length
    if (!this.wrapValue && this.indexValue <= 0) return
    this.#show((this.indexValue - 1 + length) % length)
  }

  to(event) {
    this.#show(Number(event.currentTarget.dataset.index))
  }

  keydown(event) {
    if (!this.keyboardValue) return
    if (event.key === "ArrowRight") { event.preventDefault(); this.next() }
    else if (event.key === "ArrowLeft") { event.preventDefault(); this.prev() }
  }

  pause() {
    if (this.pauseValue === "hover") this.#stop()
  }

  resume() {
    if (this.pauseValue === "hover") this.#maybeStart()
  }

  // --- private ---

  #show(index) {
    this.indexValue = index
    this.#render()
    this.#maybeStart() // restart the timer from this slide
  }

  #render() {
    this.slideTargets.forEach((slide, i) => {
      const active = i === this.indexValue
      slide.toggleAttribute("data-active", active)
      if (this.crossfadeValue) slide.classList.toggle("relative", active)
    })
    this.indicatorTargets.forEach((dot, i) => {
      if (i === this.indexValue) dot.setAttribute("aria-current", "true")
      else dot.removeAttribute("aria-current")
    })
    if (!this.wrapValue) {
      if (this.hasPrevTarget) this.prevTarget.disabled = this.indexValue === 0
      if (this.hasNextTarget) this.nextTarget.disabled = this.indexValue === this.slideTargets.length - 1
    }
  }

  #maybeStart() {
    this.#stop()
    if (!this.rideValue) return
    if (document.hidden) return
    if (!this.wrapValue && this.indexValue >= this.slideTargets.length - 1) return
    this.timer = window.setTimeout(() => this.next(), this.#currentInterval())
  }

  #stop() {
    if (this.timer) { window.clearTimeout(this.timer); this.timer = null }
  }

  #currentInterval() {
    const own = this.slideTargets[this.indexValue]?.dataset.interval
    return own ? Number(own) : this.intervalValue
  }

  #bindSwipe() {
    const viewport = this.slideTargets[0]?.parentElement
    if (!viewport) return
    let startX = null
    viewport.addEventListener("pointerdown", (e) => { startX = e.clientX })
    viewport.addEventListener("pointerup", (e) => {
      if (startX === null) return
      const dx = e.clientX - startX
      startX = null
      if (Math.abs(dx) < 40) return
      dx < 0 ? this.next() : this.prev()
    })
  }
}
