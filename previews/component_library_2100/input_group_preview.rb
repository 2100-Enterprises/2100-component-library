module ComponentLibrary2100
  # Joins a control with add-ons. Put `CONTROL` on your own control.
  # @logical_path forms
  class InputGroupPreview < BasePreview
    # @param size select { choices: ["", sm, lg] }
    def playground(size: "")
      template(:playground, size: size.presence&.to_sym)
    end
  end
end
