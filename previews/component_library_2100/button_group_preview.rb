module ComponentLibrary2100
  # Lays out buttons with shared borders. Size the buttons themselves.
  # @logical_path basics
  class ButtonGroupPreview < BasePreview
    # @param vertical toggle
    def playground(vertical: false)
      template(:playground, vertical: vertical)
    end
  end
end
