module ComponentLibrary2100
  # A native <dialog> opened with showModal() by the cl-dialog controller.
  class ModalComponentPreview < ViewComponent::Preview
    # @param title text
    # @param size select { choices: [sm, md, lg, xl] }
    # @param centered toggle
    # @param static_backdrop toggle "Ignore clicks outside the dialog"
    def playground(title: "Delete project?", size: :md, centered: false, static_backdrop: false)
      render_with_template(template: "component_library_2100/modal_component_preview/playground", locals: {title: title, size: size, centered: centered, static_backdrop: static_backdrop})
    end
  end
end
