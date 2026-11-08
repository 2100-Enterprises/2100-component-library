module ComponentLibrary2100
  # Put one in your layout, then add toasts to it:
  #
  #   <%= render ComponentLibrary2100::ToastContainerComponent.new(placement: :top_end) %>
  #   <%= turbo_stream.append "toasts", render(ComponentLibrary2100::ToastComponent.new(title: "Saved") { "Done." }) %>
  #
  # The element has id "toasts" unless you pass `id:`. placement: :top_start, :top_center, :top_end (default),
  # :bottom_start, :bottom_center, :bottom_end.
  class ToastContainerComponent < BaseComponent
    # Padding respects the device safe-area (notch / home indicator) on each side, falling back to 0.75rem.
    BASE = "fixed z-[1090] flex flex-col gap-3 pointer-events-none *:pointer-events-auto " \
           "p-[max(0.75rem,env(safe-area-inset-top))_max(0.75rem,env(safe-area-inset-right))_max(0.75rem,env(safe-area-inset-bottom))_max(0.75rem,env(safe-area-inset-left))]"

    PLACEMENTS = {
      top_start: "top-0 left-0",
      top_center: "top-0 left-1/2 -translate-x-1/2",
      top_end: "top-0 right-0",
      bottom_start: "bottom-0 left-0",
      bottom_center: "bottom-0 left-1/2 -translate-x-1/2",
      bottom_end: "bottom-0 right-0"
    }.freeze

    def initialize(placement: :top_end, **html_options)
      super(**html_options)
      @placement = placement
    end

    def call
      tag.div(content, **attrs([BASE, Variants.fetch(PLACEMENTS, @placement, kind: "placement")], id: "toasts", aria: {live: "polite", atomic: false}))
    end
  end
end
