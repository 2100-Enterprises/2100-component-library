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

    # Chips with a cap: Enter or a comma adds typed text, Backspace removes the last chip.
    # @param max number
    # @param allow_free_text toggle "Add typed text that isn't a suggestion"
    def tags(max: 3, allow_free_text: true)
      template(:tags, max: max, allow_free_text: allow_free_text)
    end
  end
end
