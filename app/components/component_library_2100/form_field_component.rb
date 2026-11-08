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
  #
  # `counter:` adds a live character count, driven by the `cl-counter` controller on the wrapper:
  #
  #   FormFieldComponent.new(control_id: "bio", counter: {max: 2000})        # "Up to 2,000 characters."
  #   FormFieldComponent.new(control_id: "pw", counter: {min: 12})           # "At least 12 characters."
  #
  # The rule is always rendered in the hint, so it reads the same without JavaScript. With
  # JavaScript a visible count ("1,950 characters left", "4 more characters needed") follows the
  # typing, and a separate visually hidden `aria-live="polite"` node repeats it after typing
  # pauses, so a screen reader doesn't announce every keystroke. The count never sets
  # `aria-invalid`; only a server error does. Options besides `min` and `max`:
  #   html: true    the control or its hidden input holds HTML (Action Text); counts text, not tags
  #   hint:         replaces the rule text in the hint
  #   left:, over:, needed:   replace the live messages; `%{count}` is the number
  # `control_options` adds the `cl-counter` target, so the control must come from it.
  class FormFieldComponent < BaseComponent
    LABEL = "inline-block mb-2"
    OPTIONAL = "font-normal text-secondary"
    HINT = "mt-1 text-sm text-secondary"
    ERROR = "mt-1 text-sm text-danger"

    CONTROL = "block w-full pointer-coarse:min-h-11 px-3 py-1.5 text-base font-normal leading-normal text-body bg-surface bg-clip-padding " \
              "border border-border-input rounded-ui appearance-none transition duration-150 placeholder:text-secondary " \
              "focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 " \
              "disabled:bg-surface-muted read-only:bg-surface-muted " \
              "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"
    # A native select keeps the browser's arrow, so it doesn't use `appearance-none`.
    SELECT = "block w-full pointer-coarse:min-h-11 px-3 py-1.5 text-base font-normal leading-normal text-body bg-surface bg-clip-padding " \
             "border border-border-input rounded-ui transition duration-150 " \
             "focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 disabled:bg-surface-muted " \
             "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"
    TEXTAREA = "#{CONTROL} min-h-[calc(1.5em+0.75rem+2px)]".freeze

    COUNTER = "mt-1 text-sm text-secondary"
    COUNTER_OPTIONS = %i[min max html hint left over needed].freeze

    CONTROLS = {control: CONTROL, select: SELECT, textarea: TEXTAREA}.freeze

    attr_reader :control_id

    def initialize(control_id:, label: nil, hint: nil, error: nil, optional: false, counter: nil, **html_options)
      super(**html_options)
      @control_id = control_id
      @label = label
      @hint = hint
      @error = error.presence
      @optional = optional
      @counter = normalize_counter(counter)
    end

    def hint_id = "#{control_id}-hint"
    def error_id = "#{control_id}-error"
    def error? = !@error.nil?

    # The ids for `aria-describedby`, or nil.
    def describedby
      [(error_id if error?), (hint_id if hint_text)].compact.join(" ").presence
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
      ).then { |merged| @counter ? merged.merge(data: (merged[:data] || {}).merge(cl_counter_target: "input")) : merged }
    end

    def call
      tag.div(safe_join([label, content, error, hint, counter].compact), **attrs(nil, **counter_data))
    end

    # The rule a counter enforces, as the hint renders it: "Up to 2,000 characters."
    def counter_rule
      return unless @counter
      return @counter[:hint] if @counter[:hint]

      min, max = @counter.values_at(:min, :max).map { |n| number(n) if n }
      if min && max then "Between #{min} and #{max} characters."
      elsif max then "Up to #{max} characters."
      else "At least #{min} characters."
      end
    end

    private

    def normalize_counter(counter)
      return unless counter

      counter = counter.to_h.symbolize_keys
      unknown = counter.keys - COUNTER_OPTIONS
      raise ArgumentError, "unknown counter option(s): #{unknown.join(", ")}" if unknown.any?
      raise ArgumentError, "counter needs min: or max:" unless counter[:min] || counter[:max]

      counter
    end

    def number(count) = ActiveSupport::NumberHelper.number_to_delimited(count)

    def hint_text
      [@hint, counter_rule].compact.join(" ").presence
    end

    def counter_data
      return {} unless @counter

      data = {controller: "cl-counter", cl_counter_html_value: @counter[:html] ? true : nil,
              cl_counter_min_value: @counter[:min], cl_counter_max_value: @counter[:max],
              cl_counter_left_message_value: @counter[:left], cl_counter_over_message_value: @counter[:over],
              cl_counter_needed_message_value: @counter[:needed]}
      {data: data.compact}
    end

    # The visible count is aria-hidden; the sr-only live region says it once typing pauses.
    def counter
      return unless @counter

      tag.div(class: COUNTER) do
        safe_join([
          tag.span(nil, data: {cl_counter_target: "count"}, aria: {hidden: true}),
          tag.span(nil, class: "sr-only", role: "status", aria: {live: "polite", atomic: true}, data: {cl_counter_target: "status"})
        ])
      end
    end

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
      tag.div(hint_text, id: hint_id, class: HINT) if hint_text
    end
  end
end
