module ComponentLibrary2100
  # A click-to-open panel on the native popover API.
  # @logical_path overlays_and_interactive
  class PopoverPreview < BasePreview
    # @param title text
    # @param placement select { choices: [top, right, bottom, left] }
    def playground(title: "Heads up", placement: "right")
      template(:playground, title: title, placement: placement)
    end
  end
end
