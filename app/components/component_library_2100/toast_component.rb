module ComponentLibrary2100
  # <%= render ToastComponent.new(title: "Saved", variant: :success) { "Your changes are live." } %>
  #
  # Render toasts inside a ToastContainerComponent: its `aria-live` region is what makes screen readers
  # announce a toast that is appended later (for example with a Turbo Stream). A toast closes itself after
  # `delay` milliseconds (5000 by default; `delay: 0` keeps it until dismissed) and has a close button
  # unless `dismissible: false`. `variant:` tints it like an Alert. `close:` passes options to that button,
  # so `close: {label: "Dismiss", class: "top-0 end-0 size-4 p-3.5"}` renames it and gives it a 44px tap target.
  class ToastComponent < BaseComponent
    BASE = "relative w-[min(350px,calc(100vw-1.5rem))] text-sm text-[#212529] bg-white/85 bg-clip-padding border border-black/10 rounded-ui shadow-md " \
           "backdrop-blur transition-opacity duration-150 motion-reduce:transition-none data-closing:opacity-0"
    MESSAGE = "p-3"
    CLOSE = "absolute top-2 end-2"

    def initialize(title: nil, variant: nil, delay: 5000, dismissible: true, close: {}, **html_options)
      super(**html_options)
      @title = title
      @variant = variant
      @delay = delay
      @dismissible = dismissible
      @close = close
    end

    def call
      tag.div(safe_join([message, close_button]), **attrs(css, data: {controller: "cl-dismiss", cl_dismiss_delay_value: @delay}))
    end

    private

    def css
      [BASE, (Variants.fetch(Variants::SUBTLE, @variant) if @variant)]
    end

    def message
      tag.div(safe_join([(tag.strong(@title, class: "block mb-1") if @title), content]), class: ComponentLibrary2100.merge_classes(MESSAGE, ("pe-10" if @dismissible)))
    end

    def close_button
      render(CloseButtonComponent.new(**merge_attrs(@close, CLOSE, data: {action: "cl-dismiss#close"}))) if @dismissible
    end
  end
end
