module ComponentLibrary2100
  class AlertComponentPreview < ViewComponent::Preview
    # @param message text
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark] }
    # @param dismissible toggle
    def playground(message: "Your changes were saved.", variant: :success, dismissible: false)
      render AlertComponent.new(variant: variant, dismissible: dismissible).with_content(message)
    end

    # The close button runs the cl-dismiss controller.
    def dismissible
      render AlertComponent.new(variant: :info, dismissible: true).with_content("Close me.")
    end
  end
end
