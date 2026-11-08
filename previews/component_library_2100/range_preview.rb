module ComponentLibrary2100
  # @logical_path forms
  class RangePreview < BasePreview
    # @param value number
    # @param step number
    # @param disabled toggle
    def playground(value: 40, step: 5, disabled: false)
      render RangeComponent.new(name: "volume", label: "Volume", hint: "0 to 100", value: value, step: step, disabled: disabled)
    end
  end
end
