import CollapseController from "component_library_2100/controllers/collapse_controller"
import DialogController from "component_library_2100/controllers/dialog_controller"
import DismissController from "component_library_2100/controllers/dismiss_controller"
import PopoverController from "component_library_2100/controllers/popover_controller"
import TabsController from "component_library_2100/controllers/tabs_controller"
import TooltipController from "component_library_2100/controllers/tooltip_controller"

export { CollapseController, DialogController, DismissController, PopoverController, TabsController, TooltipController }

// Registers every controller the library ships. Identifiers are prefixed `cl-`
// so they cannot collide with the host app's own controllers.
export function register(application) {
  application.register("cl-collapse", CollapseController)
  application.register("cl-dialog", DialogController)
  application.register("cl-dismiss", DismissController)
  application.register("cl-popover", PopoverController)
  application.register("cl-tabs", TabsController)
  application.register("cl-tooltip", TooltipController)
}
