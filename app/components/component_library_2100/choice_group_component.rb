module ComponentLibrary2100
  # <%= render ChoiceGroupComponent.new(name: "user[roles][]", legend: "Roles", type: :checkbox, checked: %w[admin],
  #       hint: "Pick any", choices: [["Admin", "admin"], ["Editor", "editor"], {value: "owner", label: "Owner", disabled: true}]) %>
  #
  # A plain group of checkboxes (`type: :checkbox`, the default) or radio buttons (`type: :radio`) in
  # a <fieldset> with a <legend>. `FormBuilder#check_boxes` and `#radios` render it. Each option is a
  # native input inside its own <label>, so the whole row is clickable and at least 44px tall.
  # Choices are `[label, value]` pairs, `{value:, label:, disabled:}` hashes or plain strings.
  #
  # `aria-describedby` on the fieldset points at the error and hint, and `aria-invalid` is set on each
  # input when there's an error. A hidden empty field comes first (`hidden: false` leaves it out), so a
  # submission with nothing checked still sends the attribute, as Rails' collection helpers do.
  # `inline: true` lays the options out in a row. `hint:`, `error:` and `optional:` work as in
  # FormFieldComponent. HTML attributes go on the <fieldset>.
  class ChoiceGroupComponent < BaseComponent
    FIELDSET = "m-0 p-0 border-0 min-w-0"
    LEGEND = "mb-2 p-0"
    LIST = "flex flex-col"
    LIST_INLINE = "flex flex-row flex-wrap gap-x-4"
    ROW = "flex items-center gap-2 min-h-11 cursor-pointer select-none has-disabled:opacity-50 has-disabled:cursor-default"
    INPUT = "size-4 shrink-0 cursor-pointer accent-primary disabled:cursor-default aria-invalid:outline aria-invalid:outline-2 " \
            "aria-invalid:outline-danger focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"

    Choice = Struct.new(:value, :label, :disabled, keyword_init: true)

    def initialize(name:, choices:, type: :checkbox, legend: nil, checked: nil, id: nil, hint: nil, error: nil, optional: false,
      inline: false, hidden: true, required: false, **html_options)
      super(**html_options)
      @name = name
      @type = choice_type(type)
      @choices = choices.map { |choice| normalize(choice) }
      @legend = legend
      @checked = Array(checked).map(&:to_s)
      @id = id || generated_id("#{@type}-group")
      @hint = hint
      @error = error.presence
      @optional = optional
      @inline = inline
      @hidden = hidden
      @required = required
    end

    def call
      parts = [legend, *messages, (tag.input(type: "hidden", name: @name, value: "", autocomplete: "off") if @hidden), list]
      tag.fieldset(safe_join(parts.compact), **attrs(FIELDSET, id: @id, aria: {describedby: describedby}.compact))
    end

    private

    def choice_type(type)
      type = type.to_sym
      raise ArgumentError, "type must be :checkbox or :radio" unless %i[checkbox radio].include?(type)

      type
    end

    def messages
      [
        (tag.div(@error, id: "#{@id}-error", class: FormFieldComponent::ERROR) if @error),
        (tag.div(@hint, id: "#{@id}-hint", class: FormFieldComponent::HINT) if @hint)
      ]
    end

    def list
      tag.div(safe_join(@choices.each_with_index.map { |choice, index| row(choice, index) }),
        class: [(@inline ? LIST_INLINE : LIST), ("mt-1" if @error || @hint)])
    end

    def legend
      return unless @legend

      marker = tag.span(@optional.is_a?(String) ? @optional : "(optional)", class: FormFieldComponent::OPTIONAL) if @optional
      tag.legend(safe_join([@legend, marker].compact, " "), class: LEGEND)
    end

    def row(choice, index)
      input_id = "#{@id}-#{index}"
      input = tag.input(type: @type.to_s, name: @name, value: choice.value, id: input_id, class: INPUT,
        checked: @checked.include?(choice.value.to_s), disabled: choice.disabled,
        required: ((@required && @type == :radio) || nil), aria: {invalid: (true if @error)}.compact)

      tag.label(safe_join([input, tag.span(choice.label)]), for: input_id, class: ROW)
    end

    def normalize(choice)
      case choice
      when Hash then Choice.new(**choice.to_h.symbolize_keys.slice(:value, :label, :disabled))
      when Array then Choice.new(label: choice[0], value: choice[1])
      else Choice.new(label: choice.to_s, value: choice.to_s)
      end
    end

    def describedby
      [("#{@id}-error" if @error), ("#{@id}-hint" if @hint)].compact.join(" ").presence
    end
  end
end
