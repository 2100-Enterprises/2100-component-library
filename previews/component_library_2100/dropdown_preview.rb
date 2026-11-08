module ComponentLibrary2100
  # A native popover menu. Arrow keys, Home and End move between items.
  # @logical_path overlays_and_interactive
  class DropdownPreview < BasePreview
    # @param placement select { choices: [bottom-start, bottom-end, top-start, top-end, right, left] }
    def playground(placement: "bottom-start")
      template(:playground, placement: placement)
    end
  end
end
