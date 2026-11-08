module ComponentLibrary2100
  # Suggestions load from `src` into a Turbo Frame. In Lookbook, /examples/people answers with
  # people whose names match.
  # @logical_path forms
  class ComboboxPreview < BasePreview
    # @param force_selection toggle "Clear text that doesn't match an option"
    # @param min_length number
    def playground(force_selection: false, min_length: 1)
      template(:playground, force_selection: force_selection, min_length: min_length)
    end
  end
end
