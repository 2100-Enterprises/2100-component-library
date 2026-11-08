module ComponentLibrary2100
  # A removable value, such as an active filter. Without `remove:` it's a static <span>.
  # @logical_path data_display
  class ChipPreview < BasePreview
    # @param label text
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark] }
    # @param removable toggle "Render the remove link"
    def playground(label: "Open", variant: :secondary, removable: true)
      render ChipComponent.new(label: label, variant: variant, remove: (removable ? "#" : nil))
    end

    # A non-GET `remove:` renders a small form, so it keeps the CSRF token.
    # @label Remove with DELETE
    def remove_with_delete
      render ChipComponent.new(label: "Ada Lovelace", variant: :primary, remove: {href: "#", method: :delete})
    end
  end
end
