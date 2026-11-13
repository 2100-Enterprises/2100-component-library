module ComponentLibrary2100
  # <%= ui_pwa_install app_name: "2100 Enterprises" %>
  #
  # An "install this app" banner, pinned to the bottom of the screen (bottom right from `sm`). It
  # renders hidden; the cl-pwa-install controller shows it only where installing can work: a one-tap
  # Install button where the browser fires beforeinstallprompt (Chromium on Android and desktop), and
  # Add to Home Screen guidance on iOS Safari. It never shows inside the installed app, and "Not now"
  # or the close button hides it for `dismiss_days` days.
  #
  # icon: an image path or URL, shown at 40px. Defaults to the shared 2100 PWA icon; pass false for none.
  # message: the line above the Install button. ios_message: the guidance on iOS. close: passes
  # options to the close button, as Toast does, so `close: {class: "size-4 p-3.5"}` sizes it to 44px
  # on every screen rather than only on touch screens.
  class PwaInstallComponent < BaseComponent
    BASE = "fixed inset-x-0 bottom-0 z-50 px-4 pb-[max(1rem,env(safe-area-inset-bottom))] sm:left-auto sm:right-4 sm:max-w-sm"
    CARD = "flex items-start gap-3 rounded-ui border border-border bg-surface p-4 text-body shadow-xl"
    SECONDARY = "min-h-11 text-sm font-medium text-body-muted hover:text-body cursor-pointer active:scale-[.98]"
    DEFAULT_ICON = "component_library_2100/pwa/icon-192.png"

    def initialize(app_name:, icon: DEFAULT_ICON, message: nil, ios_message: nil, install_label: "Install", dismiss_days: 30, close: {}, **html_options)
      super(**html_options)
      @app_name = app_name
      @icon = icon
      @message = message || "Add #{app_name} to your home screen for quick access."
      @ios_message = ios_message
      @install_label = install_label
      @dismiss_days = dismiss_days
      @close = close
    end

    def call
      tag.div(**attrs(BASE, hidden: true, role: "region", aria: {label: "Install #{@app_name}"},
        data: {controller: "cl-pwa-install", cl_pwa_install_dismiss_days_value: @dismiss_days})) do
        tag.div(class: CARD) { safe_join([icon, body, close_button].compact) }
      end
    end

    private

    def icon
      helpers.image_tag(@icon, alt: "", width: 40, height: 40, class: "size-10 shrink-0 rounded-xl") if @icon
    end

    def body
      tag.div(class: "min-w-0 flex-1") do
        safe_join([tag.p("Install #{@app_name}", class: "font-semibold"), prompt_actions, ios_actions])
      end
    end

    def prompt_actions
      tag.div(hidden: true, class: "mt-1", data: {cl_pwa_install_target: "promptActions"}) do
        safe_join([
          tag.p(@message, class: "text-sm text-body-muted"),
          tag.div(class: "mt-3 flex items-center gap-3") do
            safe_join([
              render(ButtonComponent.new(size: :sm, class: "min-h-11", data: {action: "cl-pwa-install#install"})) { @install_label },
              dismiss_button("Not now")
            ])
          end
        ])
      end
    end

    def ios_actions
      tag.div(hidden: true, class: "mt-1", data: {cl_pwa_install_target: "iosActions"}) do
        safe_join([
          tag.p(@ios_message || ios_guidance, class: "text-sm text-body-muted"),
          tag.div(dismiss_button("Got it"), class: "mt-3")
        ])
      end
    end

    def ios_guidance
      safe_join(["Tap the Share button, then ", tag.span("Add to Home Screen", class: "font-medium text-body"), "."])
    end

    def dismiss_button(label)
      tag.button(label, type: :button, class: SECONDARY, data: {action: "cl-pwa-install#dismiss"})
    end

    def close_button
      render(CloseButtonComponent.new(**merge_attrs(@close, "-m-1 shrink-0", label: "Dismiss install prompt",
        data: {action: "cl-pwa-install#dismiss"})))
    end
  end
end
