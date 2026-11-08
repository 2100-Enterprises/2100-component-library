module ComponentLibrary2100
  # Shows on hover and focus. Wrap something focusable.
  # @logical_path overlays_and_interactive
  class TooltipPreview < BasePreview
    # @param text text
    # @param placement select { choices: [top, bottom, left, right, top-start, top-end, bottom-start, bottom-end] }
    def playground(text: "Copy to clipboard", placement: "top")
      template(:playground, text: text, placement: placement)
    end
  end
end
