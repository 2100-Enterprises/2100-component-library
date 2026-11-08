module ComponentLibrary2100
  # `white: true` is for a dark fill. Otherwise it follows the theme.
  # @logical_path basics
  class CloseButtonPreview < BasePreview
    # @param label text "Accessible name"
    def playground(label: "Close")
      template(:playground, label: label)
    end
  end
end
