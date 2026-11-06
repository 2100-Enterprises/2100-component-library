module ComponentLibrary2100
  # <%= render AlertComponent.new(variant: :danger, dismissible: true) { "Something broke." } %>
  #
  # Dismissing needs the `cl-dismiss` Stimulus controller (registered by the install generator).
  class AlertComponent < BaseComponent
    BASE = "relative p-4 border rounded-ui transition-opacity duration-150 motion-reduce:transition-none"
    CLOSE = "absolute top-0 end-0 z-[2] px-4 py-5"

    def initialize(variant: :primary, dismissible: false, **html_options)
      super(**html_options)
      @variant = variant
      @dismissible = dismissible
    end

    def call
      tag.div(safe_join([content, close_button]), **attrs(css, role: "alert", data: data))
    end

    private

    def css
      [BASE, Variants.fetch(Variants::SUBTLE, @variant), ("pe-12" if @dismissible)]
    end

    def data
      @dismissible ? {controller: "cl-dismiss"} : {}
    end

    def close_button
      return unless @dismissible

      render CloseButtonComponent.new(class: CLOSE, data: {action: "cl-dismiss#close"})
    end
  end
end
