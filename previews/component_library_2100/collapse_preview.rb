module ComponentLibrary2100
  # Driven by cl-collapse. The panel animates with a grid-rows transition.
  # @logical_path overlays_and_interactive
  class CollapsePreview < BasePreview
    # @param open toggle "Start expanded"
    def playground(open: false)
      template(:playground, open: open)
    end
  end
end
