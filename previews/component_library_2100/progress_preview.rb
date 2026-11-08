module ComponentLibrary2100
  # @logical_path feedback
  class ProgressPreview < BasePreview
    # @param value number
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark] }
    # @param striped toggle
    # @param animated toggle
    # @param show_label toggle "Show the percentage"
    def playground(value: 40, variant: :primary, striped: false, animated: false, show_label: true)
      render ProgressComponent.new(value: value, variant: variant, striped: striped, animated: animated,
        label: show_label || nil, aria: {label: "Upload"})
    end
  end
end
