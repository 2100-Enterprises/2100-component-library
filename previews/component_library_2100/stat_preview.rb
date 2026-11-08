module ComponentLibrary2100
  # @logical_path data_display
  class StatPreview < BasePreview
    # @param label text
    # @param value text
    # @param change text
    # @param trend select { choices: ["", up, down, flat] }
    # @param hint text
    def playground(label: "Revenue", value: "$12,400", change: "8%", trend: "up", hint: "vs. last month")
      render StatComponent.new(label: label, value: value, change: change.presence, trend: trend.presence&.to_sym, hint: hint.presence)
    end

    # `variant:` recolours the change when down is good, as for costs.
    def falling_costs
      render StatComponent.new(label: "Costs", value: "$3,100", change: "4%", trend: :down, variant: :success)
    end
  end
end
