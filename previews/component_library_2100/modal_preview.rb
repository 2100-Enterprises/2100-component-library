module ComponentLibrary2100
  # A native <dialog> opened with showModal() by the cl-dialog controller.
  # @logical_path overlays_and_interactive
  class ModalPreview < BasePreview
    # @param title text
    # @param size select { choices: [sm, md, lg, xl] }
    # @param centered toggle
    # @param static_backdrop toggle "Ignore clicks outside the dialog"
    def playground(title: "Delete project?", size: :md, centered: false, static_backdrop: false)
      template(:playground, title: title, size: size, centered: centered, static_backdrop: static_backdrop)
    end
  end
end
