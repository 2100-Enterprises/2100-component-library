module ComponentLibrary2100
  # Built on <details>, so it needs no JavaScript. Items close each other unless `always_open:`.
  # @logical_path overlays_and_interactive
  class AccordionPreview < BasePreview
    # @param always_open toggle "Let several items stay open"
    def playground(always_open: false)
      template(:playground, always_open: always_open)
    end
  end
end
