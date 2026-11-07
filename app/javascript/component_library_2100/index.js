import AutosubmitController from "component_library_2100/controllers/autosubmit_controller"
import CollapseController from "component_library_2100/controllers/collapse_controller"
import ConfirmController from "component_library_2100/controllers/confirm_controller"
import DialogController from "component_library_2100/controllers/dialog_controller"
import DismissController from "component_library_2100/controllers/dismiss_controller"
import PasswordController from "component_library_2100/controllers/password_controller"
import PopoverController from "component_library_2100/controllers/popover_controller"
import TabsController from "component_library_2100/controllers/tabs_controller"
import TooltipController from "component_library_2100/controllers/tooltip_controller"

export {
  AutosubmitController, CollapseController, ConfirmController, DialogController, DismissController,
  PasswordController, PopoverController, TabsController, TooltipController
}

// Registers every controller the library ships. Identifiers are prefixed `cl-`
// so they cannot collide with the host app's own controllers.
export function register(application) {
  application.register("cl-autosubmit", AutosubmitController)
  application.register("cl-collapse", CollapseController)
  application.register("cl-confirm", ConfirmController)
  application.register("cl-dialog", DialogController)
  application.register("cl-dismiss", DismissController)
  application.register("cl-password", PasswordController)
  application.register("cl-popover", PopoverController)
  application.register("cl-tabs", TabsController)
  application.register("cl-tooltip", TooltipController)
}

// A Turbo confirm method that asks with the page's ConfirmDialogComponent (`ui_confirm_dialog`
// in your layout) and falls back to window.confirm when there isn't one. It reads optional
// `data-turbo-confirm-title` and `data-turbo-confirm-accept` from the submit button or the form.
export function confirmMethod(message, element, submitter) {
  if (!document.querySelector("[data-controller~='cl-confirm']")) return Promise.resolve(window.confirm(message))

  const read = (name) => submitter?.getAttribute(name) || element?.getAttribute(name) || undefined

  return new Promise((resolve) => {
    window.dispatchEvent(new CustomEvent("cl-confirm:open", {
      detail: { message, title: read("data-turbo-confirm-title"), accept: read("data-turbo-confirm-accept"), resolve }
    }))
  })
}

// Makes Turbo use confirmMethod for `data-turbo-confirm`. Turbo 8 reads Turbo.config.forms.confirm;
// older versions only have Turbo.setConfirmMethod.
export function useStyledConfirm(Turbo) {
  if (Turbo.config?.forms) Turbo.config.forms.confirm = confirmMethod
  else Turbo.setConfirmMethod(confirmMethod)
}
