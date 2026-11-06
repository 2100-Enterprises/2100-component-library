module ComponentLibrary2100
  # <%= render AlertComponent.new(variant: :danger, dismissible: true) { "Something broke." } %>
  #
  # Dismissing needs the `cl-dismiss` Stimulus controller (registered by the install generator).
  # The close button sits beside the alert, in a wrapper that holds the controller, so screen
  # readers don't announce it as part of the message. HTML attributes stay on the alert itself,
  # except `data-controller`, which joins `cl-dismiss` on the wrapper so it hears `cl-dismiss:close`.
  class AlertComponent < BaseComponent
    BASE = "relative p-4 border rounded-ui"
    WRAPPER = "relative transition-opacity duration-150 motion-reduce:transition-none data-closing:opacity-0"
    CLOSE = "absolute top-0 end-0 z-[2] px-4 py-5"

    def initialize(variant: :primary, dismissible: false, **html_options)
      super(**html_options)
      @variant = variant
      @dismissible = dismissible
    end

    def call
      return alert unless @dismissible

      tag.div(safe_join([alert, close_button]), class: WRAPPER, data: {controller: wrapper_controllers})
    end

    private

    def alert
      tag.div(content, **merge_attrs(alert_options, css, role: "alert"))
    end

    def alert_options
      return html_options unless @dismissible && html_options[:data]

      html_options.merge(data: html_options[:data].except(:controller))
    end

    def wrapper_controllers
      ["cl-dismiss", html_options.dig(:data, :controller)].compact.join(" ")
    end

    def css
      [BASE, Variants.fetch(Variants::SUBTLE, @variant), ("pe-12" if @dismissible)]
    end

    def close_button
      render CloseButtonComponent.new(class: CLOSE, data: {action: "cl-dismiss#close"})
    end
  end
end
