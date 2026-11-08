// Registers the app's service worker once the page has loaded, so it never competes with the
// first render. Serve the worker from the site root (Rails' rails/pwa#service_worker does, at
// /service-worker) so its scope covers every page. Resolves with the registration, or null when
// the browser has no service workers or registration fails.
//
//   import { registerServiceWorker } from "component_library_2100/pwa"
//   registerServiceWorker()
export function registerServiceWorker(url = "/service-worker", options = {}) {
  if (!("serviceWorker" in navigator)) return Promise.resolve(null)

  const register = () => navigator.serviceWorker.register(url, options).catch(() => null)

  if (document.readyState === "complete") return register()
  return new Promise((resolve) => window.addEventListener("load", () => resolve(register()), { once: true }))
}

// True when the page is running as an installed app rather than in a browser tab.
export function isStandalone() {
  return window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true
}
