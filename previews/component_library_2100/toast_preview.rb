module ComponentLibrary2100
  # Render toasts in a ToastContainer, whose live region announces them.
  # @logical_path feedback
  class ToastPreview < BasePreview
    # @param title text
    # @param body text
    # @param variant select { choices: ["", primary, secondary, success, danger, warning, info, light, dark] }
    # @param delay number "Milliseconds before it closes; 0 keeps it"
    # @param dismissible toggle
    def playground(title: "Saved", body: "Your changes are live.", variant: "", delay: 0, dismissible: true)
      template(:playground, title: title, body: body, variant: variant.presence&.to_sym, delay: delay, dismissible: dismissible)
    end
  end
end
