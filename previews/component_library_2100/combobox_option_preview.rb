module ComponentLibrary2100
  # @logical_path forms
  class ComboboxOptionPreview < BasePreview
    # What a Combobox endpoint renders. The listbox around them is the Combobox's, added here so
    # they read as they would there.
    def default
      template(:default)
    end
  end
end
