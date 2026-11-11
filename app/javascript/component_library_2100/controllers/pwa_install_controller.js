import { Controller } from "@hotwired/stimulus"
import { isStandalone } from "component_library_2100/pwa"

// Drives PwaInstallComponent. On Chromium (Android, desktop) it catches beforeinstallprompt and
// shows a one-tap Install button; on iOS Safari, which has no prompt, it shows Add to Home Screen
// guidance instead. It stays hidden when the app is already installed, and a dismissal is
// remembered for `dismiss-days` days (0 forgets it on the next page load).
//
// Events, none cancelable: `cl-pwa-install:shown` (detail.platform is "prompt" or "ios"),
// `cl-pwa-install:accepted`, `cl-pwa-install:declined` and `cl-pwa-install:dismissed`.
export default class extends Controller {
  static targets = ["promptActions", "iosActions"]
  static values = { dismissDays: { type: Number, default: 30 }, storageKey: { type: String, default: "cl-pwa-install-dismissed-at" } }

  connect() {
    if (isStandalone() || this.recentlyDismissed) return

    this.onBeforeInstallPrompt = (event) => {
      event.preventDefault()
      this.deferredPrompt = event
      this.show("prompt")
    }
    this.onAppInstalled = () => this.remove()
    window.addEventListener("beforeinstallprompt", this.onBeforeInstallPrompt)
    window.addEventListener("appinstalled", this.onAppInstalled)

    if (this.isIosSafari) this.show("ios")
  }

  disconnect() {
    window.removeEventListener("beforeinstallprompt", this.onBeforeInstallPrompt)
    window.removeEventListener("appinstalled", this.onAppInstalled)
  }

  async install() {
    if (!this.deferredPrompt) return

    const prompt = this.deferredPrompt
    this.deferredPrompt = null
    prompt.prompt()
    const { outcome } = await prompt.userChoice
    this.dispatch(outcome === "accepted" ? "accepted" : "declined", { bubbles: true })
    this.remove()
  }

  dismiss() {
    try {
      localStorage.setItem(this.storageKeyValue, Date.now().toString())
    } catch {
      // Storage is off (private mode); hiding it for this page view is enough.
    }
    this.dispatch("dismissed", { bubbles: true })
    this.remove()
  }

  show(platform) {
    const actions = platform === "ios" ? this.iosActionsTarget : this.promptActionsTarget
    actions.hidden = false
    this.element.hidden = false
    this.dispatch("shown", { detail: { platform }, bubbles: true })
  }

  remove() {
    this.element.remove()
  }

  get recentlyDismissed() {
    try {
      const at = parseInt(localStorage.getItem(this.storageKeyValue) || "", 10)
      return Boolean(at) && Date.now() - at < this.dismissDaysValue * 24 * 60 * 60 * 1000
    } catch {
      return false
    }
  }

  // iPadOS reports itself as a Mac, so a Mac with touch counts. Chrome, Firefox and Edge on iOS
  // can't add to the Home Screen the Safari way, so they don't get the guidance.
  get isIosSafari() {
    const { userAgent, platform, maxTouchPoints } = window.navigator
    const ios = /iphone|ipad|ipod/i.test(userAgent) || (platform === "MacIntel" && maxTouchPoints > 1)
    return ios && /safari/i.test(userAgent) && !/crios|fxios|edgios/i.test(userAgent)
  }
}
