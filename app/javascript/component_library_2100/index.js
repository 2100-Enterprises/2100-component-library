import DismissController from "component_library_2100/controllers/dismiss_controller"

export { DismissController }

// Registers every controller the library ships. Identifiers are prefixed `cl-`
// so they cannot collide with the host app's own controllers.
export function register(application) {
  application.register("cl-dismiss", DismissController)
}
