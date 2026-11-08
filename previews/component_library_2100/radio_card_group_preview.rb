module ComponentLibrary2100
  # Radio buttons drawn as cards. Arrow keys move between them as in any radio group.
  # @logical_path forms
  class RadioCardGroupPreview < BasePreview
    # @param columns select { choices: [1, 2, 3] }
    # @param error text
    def playground(columns: 3, error: "")
      render RadioCardGroupComponent.new(name: "plan", legend: "Plan", checked: "pro", columns: columns.to_i, error: error.presence,
        choices: [
          {value: "basic", label: "Basic", description: "One project"},
          {value: "pro", label: "Pro", description: "Unlimited projects"},
          {value: "legacy", label: "Legacy", description: "No longer offered", disabled: true}
        ])
    end
  end
end
