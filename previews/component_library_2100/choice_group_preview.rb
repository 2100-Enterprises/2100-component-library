module ComponentLibrary2100
  # Native checkboxes or radio buttons in a <fieldset> with a <legend>.
  # @logical_path forms
  class ChoiceGroupPreview < BasePreview
    # @param type select { choices: [checkbox, radio] }
    # @param inline toggle
    # @param hint text
    # @param error text
    def playground(type: :checkbox, inline: false, hint: "Pick any that apply.", error: "")
      render ChoiceGroupComponent.new(
        name: (type == :radio) ? "contact" : "roles[]", type: type, legend: "Roles", inline: inline,
        hint: hint.presence, error: error.presence, checked: %w[editor],
        choices: [["Admin", "admin"], ["Editor", "editor"], {value: "owner", label: "Owner", disabled: true}]
      )
    end
  end
end
