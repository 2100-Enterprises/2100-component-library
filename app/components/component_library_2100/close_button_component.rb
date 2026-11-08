module ComponentLibrary2100
  # <%= render CloseButtonComponent.new(data: { action: "cl-dismiss#close" }) %>
  class CloseButtonComponent < BaseComponent
    BASE = "#{Variants::TOUCH_TARGET} box-content size-[1em] p-[.25em] rounded-ui border-0 bg-transparent cursor-pointer opacity-50 hover:opacity-75 " \
           "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"

    ICON = "M.293.293a1 1 0 0 1 1.414 0L8 6.586 14.293.293a1 1 0 1 1 1.414 1.414L9.414 8l6.293 6.293a1 1 0 0 1-1.414 1.414L8 9.414l-6.293 6.293a1 1 0 0 1-1.414-1.414L6.586 8 .293 1.707a1 1 0 0 1 0-1.414z"

    # label: the accessible name. white: always white, for a dark fill. Otherwise the close token, which
    # follows dark mode.
    def initialize(label: "Close", white: false, **html_options)
      super(**html_options)
      @label = label
      @white = white
    end

    def call
      tag.button(icon, **attrs([BASE, @white ? "text-white" : "text-close"], type: :button, aria: {label: @label}))
    end

    private

    def icon
      tag.svg(tag.path(d: ICON), viewBox: "0 0 16 16", fill: "currentColor", class: "size-full", aria: {hidden: true})
    end
  end
end
