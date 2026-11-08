module ComponentLibrary2100
  # Driven by cl-carousel: arrows, indicator dots, arrow keys, swipe and autoplay that pauses on hover.
  # @logical_path overlays_and_interactive
  class CarouselPreview < BasePreview
    # @param ride toggle "Autoplay on load"
    # @param crossfade toggle
    # @param controls toggle
    # @param indicators toggle
    # @param wrap toggle "Cycle past the ends"
    def playground(ride: false, crossfade: false, controls: true, indicators: true, wrap: true)
      template(:playground, ride: ride, crossfade: crossfade, controls: controls, indicators: indicators, wrap: wrap)
    end
  end
end
