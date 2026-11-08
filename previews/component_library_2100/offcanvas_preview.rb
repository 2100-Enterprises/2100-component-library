module ComponentLibrary2100
  # A modal <dialog> docked to an edge, with the same slots as Modal.
  # @logical_path overlays_and_interactive
  class OffcanvasPreview < BasePreview
    # @param title text
    # @param placement select { choices: [start, end, top, bottom] }
    # @param static_backdrop toggle "Ignore clicks outside the panel"
    def playground(title: "Filters", placement: :start, static_backdrop: false)
      template(:playground, title: title, placement: placement, static_backdrop: static_backdrop)
    end
  end
end
