module ComponentLibrary2100
  # <%= render FileUploadComponent.new(name: "document[file]", label: "Add a file", accept: %w[.pdf .docx image/*], max_bytes: 5.megabytes) %>
  #
  # A native `<input type="file">` in a multipart form, with the browser's file button styled to match
  # the library. It works with no JavaScript: the form posts the file and the server is the source of
  # truth for size and type. With JavaScript (cl-file-upload) the chosen files appear in a list with their
  # human size and a "Remove <filename>" button, a warning when a file is over `max_bytes:` or isn't one
  # of `accept:`, and a polite live region announces what happened.
  #
  # `accept:` takes an array or a comma string and is joined with commas and no spaces, because browsers
  # ignore it otherwise. `max_label:` defaults to a human size derived from `max_bytes:` ("5 MB").
  # `multiple: true` lists every file; removing one rebuilds `input.files` through a DataTransfer.
  # `error:` is the server's message, wired with aria-invalid and aria-describedby.
  #
  # `dropzone: true` wraps the input in a dashed region that highlights while a file is dragged over it
  # and takes dropped files into the input. The input stays the keyboard path, and the region isn't focusable.
  #
  # A rejected file (too big, wrong type) is flagged but kept. In the single-file case that lets the form
  # submit and reach the server's error path, as a person without JavaScript would; the warning and the
  # Remove button let them fix it first. Nothing is dropped silently.
  #
  # Active Storage: if the input has `data-direct-upload-url` (`data: {direct_upload_url: url}`), the
  # `direct-upload:*` events drive a progress bar (ProgressComponent) under the list.
  #
  # HTML attributes go on the input, so `class:`, `data:` and `aria:` pass through. FormBuilder#file_upload
  # renders this for a model attribute.
  class FileUploadComponent < BaseComponent
    INPUT = "block w-auto max-w-full min-h-11 text-sm text-body group-data-[enhanced]:text-transparent " \
            "file:mr-3 file:min-h-11 file:cursor-pointer file:rounded-ui file:border file:border-primary file:bg-surface " \
            "file:px-4 file:font-semibold file:text-primary hover:file:bg-primary/5 " \
            "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25 " \
            "aria-invalid:file:border-danger aria-invalid:file:text-danger disabled:opacity-50"
    ZONE = "rounded-ui border-2 border-dashed border-border-input p-4 transition-colors " \
           "data-[dragging]:border-primary data-[dragging]:bg-primary/5"
    DROP_TEXT = "mt-1 text-sm text-secondary"
    LIST = "mt-2 space-y-2"
    ITEM = "flex flex-wrap items-center gap-x-3 gap-y-1 rounded-ui border border-border bg-surface px-3 py-2"
    NAME = "break-all font-semibold"
    SIZE = "text-sm text-secondary"
    REMOVE = "ml-auto min-h-11 min-w-11 px-2 text-sm font-semibold text-primary hover:underline " \
             "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25 rounded-ui"
    WARNING = "w-full text-sm font-semibold text-danger"
    STATUS = "sr-only"

    def initialize(name: nil, label: nil, hint: nil, error: nil, accept: nil, max_bytes: nil, max_label: nil,
      multiple: false, dropzone: false, required: false, id: nil, **html_options)
      super(**html_options)
      @name = name
      @label = label
      @hint = hint
      @error = error.presence
      @accept = Array(accept).flat_map { |value| value.to_s.split(/[\s,]+/) }.compact_blank.join(",").presence
      @max_bytes = max_bytes
      @max_label = max_label || (human_size(max_bytes) if max_bytes)
      @multiple = multiple
      @dropzone = dropzone
      @required = required
      @id = id || generated_id("file-upload")
    end

    def call
      tag.div(safe_join([label, field, hint, error, list, progress, status].compact), class: "group", data: root_data)
    end

    private

    def root_data
      {controller: "cl-file-upload", cl_file_upload_max_bytes_value: @max_bytes, cl_file_upload_max_label_value: @max_label,
       action: "direct-upload:initialize->cl-file-upload#uploadStart direct-upload:progress->cl-file-upload#uploadProgress " \
               "direct-upload:end->cl-file-upload#uploadEnd direct-upload:error->cl-file-upload#uploadError"}.compact
    end

    def label
      tag.label(@label, for: @id, class: FormFieldComponent::LABEL) if @label
    end

    def field
      return input unless @dropzone

      tag.div(safe_join([input, tag.p("Or drop #{@multiple ? "files" : "a file"} here.", class: DROP_TEXT)]), class: ZONE,
        data: {cl_file_upload_target: "zone",
               action: "dragover->cl-file-upload#dragover dragleave->cl-file-upload#dragleave drop->cl-file-upload#drop"})
    end

    def input
      tag.input(**attrs(INPUT, type: "file", name: input_name, id: @id, accept: @accept, multiple: @multiple, required: @required,
        data: {cl_file_upload_target: "input", action: "change->cl-file-upload#render"},
        aria: {describedby: describedby, invalid: (true if @error)}.compact))
    end

    def input_name
      @multiple && @name && !@name.to_s.end_with?("[]") ? "#{@name}[]" : @name
    end

    def hint
      tag.div(@hint, id: hint_id, class: FormFieldComponent::HINT) if @hint
    end

    def error
      tag.div(@error, id: error_id, class: FormFieldComponent::ERROR) if @error
    end

    def hint_id = "#{@id}-hint"

    def error_id = "#{@id}-error"

    def describedby
      [(error_id if @error), (hint_id if @hint)].compact.join(" ").presence
    end

    # The staged files. Rows are cloned from the template, so the markup and classes stay here.
    def list
      tag.ul(id: "#{@id}-list", hidden: true, class: LIST, data: {cl_file_upload_target: "list"}) +
        tag.template(item, data: {cl_file_upload_target: "template"})
    end

    def item
      tag.li(safe_join([
        tag.span(class: NAME, data: {name: true}),
        tag.span(class: SIZE, data: {size: true}),
        tag.button("Remove", type: "button", class: REMOVE, data: {remove: true, action: "cl-file-upload#remove"}),
        tag.p(class: WARNING, hidden: true, data: {warning: true})
      ]), class: ITEM)
    end

    # Shown only while Active Storage reports direct-upload progress.
    def progress
      tag.div(render(ProgressComponent.new(value: 0, label: true, aria: {label: "Upload progress"})),
        hidden: true, class: "mt-2", data: {cl_file_upload_target: "progress"})
    end

    def status
      tag.p(role: "status", class: STATUS, data: {cl_file_upload_target: "status"})
    end

    def human_size(bytes)
      return "#{bytes} B" if bytes < 1024
      return "#{format("%.1f", bytes / 1024.0).delete_suffix(".0")} KB" if bytes < 1024 * 1024

      "#{format("%.1f", bytes / 1024.0 / 1024).delete_suffix(".0")} MB"
    end
  end
end
