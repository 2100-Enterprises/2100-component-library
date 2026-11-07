module ComponentLibrary2100
  # Label, control, error and hint for one form field. ComponentLibrary2100::FormBuilder renders
  # these for you; use the component directly for a control the builder doesn't cover:
  #
  # <%= render FormFieldComponent.new(label: "Email", control_id: "email", hint: "We never share it.", error: @error) do |field| %>
  #   <%= email_field_tag "email", nil, **field.control_options %>
  # <% end %>
  #
  # `control_options` returns the control's `id`, its Bootstrap form-control classes and the
  # aria wiring: `aria-describedby` points at the error and hint, and `aria-invalid` is set when
  # there's an error, which also turns the border red. `optional: true` adds "(optional)" to the
  # label (pass a string to change the wording). `label: false` renders no label, so give the
  # control an `aria: {label: ...}` yourself. HTML attributes go on the wrapper <div>.
  class FormFieldComponent < BaseComponent
    LABEL = "inline-block mb-2"
    OPTIONAL = "font-normal text-secondary"
    HINT = "mt-1 text-sm text-secondary"
    ERROR = "mt-1 text-sm text-danger"

    CONTROL = "block w-full px-3 py-1.5 text-base font-normal leading-normal text-body bg-surface bg-clip-padding " \
              "border border-border-input rounded-ui appearance-none transition duration-150 placeholder:text-secondary " \
              "focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 " \
              "disabled:bg-surface-muted read-only:bg-surface-muted " \
              "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"
    # A native select keeps the browser's arrow, so it doesn't use `appearance-none`.
    SELECT = "block w-full px-3 py-1.5 text-base font-normal leading-normal text-body bg-surface bg-clip-padding " \
             "border border-border-input rounded-ui transition duration-150 " \
             "focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 disabled:bg-surface-muted " \
             "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"
    TEXTAREA = "#{CONTROL} min-h-[calc(1.5em+0.75rem+2px)]".freeze

    CONTROLS = {control: CONTROL, select: SELECT, textarea: TEXTAREA}.freeze

    attr_reader :control_id

    def initialize(control_id:, label: nil, hint: nil, error: nil, optional: false, **html_options)
      super(**html_options)
      @control_id = control_id
      @label = label
      @hint = hint
      @error = error.presence
      @optional = optional
    end

    def hint_id = "#{control_id}-hint"
    def error_id = "#{control_id}-error"
    def error? = !@error.nil?

    # The ids for `aria-describedby`, or nil.
    def describedby
      [(error_id if error?), (hint_id if @hint)].compact.join(" ").presence
    end

    # Options for the control element. Your own `class:` is merged; `aria:` is deep merged.
    #   kind: :control (inputs), :select or :textarea
    #   field.control_options(class: "w-64")  or  field.control_options(options_hash, kind: :select)
    def control_options(options = {}, kind: :control, **attributes)
      options = options.to_h.symbolize_keys.merge(attributes)
      aria = {describedby: describedby, invalid: (true if error?)}.compact

      options.merge(
        id: options[:id] || control_id,
        class: ComponentLibrary2100.merge_classes(Variants.fetch(CONTROLS, kind, kind: "control kind"), options[:class]),
        aria: aria.merge(options[:aria] || {})
      )
    end

    def call
      tag.div(safe_join([label, content, error, hint].compact), **attrs(nil))
    end

    private

    def label
      return if @label == false || @label.nil?

      tag.label(safe_join([@label, optional_marker].compact, " "), for: control_id, class: LABEL)
    end

    def optional_marker
      return unless @optional

      tag.span(@optional.is_a?(String) ? @optional : "(optional)", class: OPTIONAL)
    end

    def error
      tag.div(@error, id: error_id, class: ERROR) if error?
    end

    def hint
      tag.div(@hint, id: hint_id, class: HINT) if @hint
    end
  end
end
