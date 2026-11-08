module ComponentLibrary2100
  # Label, control, error and hint for a control the FormBuilder doesn't cover.
  # @logical_path forms
  class FormFieldPreview < BasePreview
    # @param label text
    # @param hint text
    # @param error text
    # @param optional toggle
    def playground(label: "Email", hint: "We never share it.", error: "", optional: false)
      template(:playground, label: label, hint: hint.presence, error: error.presence, optional: optional)
    end

    # `counter:` adds a live character count, driven by cl-counter.
    # @param max number
    def counter(max: 140)
      template(:counter, max: max)
    end
  end
end
