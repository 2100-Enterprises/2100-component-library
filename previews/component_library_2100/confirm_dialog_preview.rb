module ComponentLibrary2100
  # The dialog behind `data-turbo-confirm`. The preview layout hands Turbo the library's
  # confirm method with `useStyledConfirm`, as a host app does.
  # @logical_path overlays_and_interactive
  class ConfirmDialogPreview < BasePreview
    # @param title text
    # @param accept text "Confirm button text"
    # @param variant select { choices: [primary, danger, warning] }
    def playground(title: "Are you sure?", accept: "Delete", variant: :danger)
      template(:playground, title: title, accept: accept, variant: variant)
    end
  end
end
