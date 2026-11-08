module ComponentLibrary2100
  # A checkbox, radio or switch with its label. A switch is a checkbox with role="switch".
  # @logical_path forms
  class SwitchPreview < BasePreview
    # @param label text
    # @param type select { choices: [switch, checkbox, radio] }
    # @param checked toggle
    # @param disabled toggle
    # @param hint text
    # @param error text
    def playground(label: "Email me updates", type: :switch, checked: true, disabled: false, hint: "", error: "")
      render SwitchComponent.new(name: "newsletter", label: label, type: type, checked: checked, disabled: disabled,
        hint: hint.presence, error: error.presence)
    end
  end
end
