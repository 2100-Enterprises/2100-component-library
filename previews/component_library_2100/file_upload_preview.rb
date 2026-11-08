module ComponentLibrary2100
  # A native file input. cl-file-upload lists the chosen files and flags ones that are too big
  # or the wrong type. Nothing is uploaded in Lookbook.
  # @logical_path forms
  class FileUploadPreview < BasePreview
    # @param multiple toggle
    # @param dropzone toggle
    # @param error text "A server error"
    def playground(multiple: false, dropzone: false, error: "")
      render FileUploadComponent.new(name: "document[file]", label: "Add a file", hint: "PDF, Word or an image.",
        accept: %w[.pdf .docx image/*], max_bytes: 5.megabytes, multiple: multiple, dropzone: dropzone, error: error.presence)
    end
  end
end
