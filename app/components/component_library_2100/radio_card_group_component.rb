module ComponentLibrary2100
  # <%= render RadioCardGroupComponent.new(name: "plan", legend: "Plan", checked: "pro", columns: 2, choices: [
  #       {value: "basic", label: "Basic", description: "One project"},
  #       {value: "pro", label: "Pro", description: "Unlimited projects"},
  #       {value: "legacy", label: "Legacy", disabled: true}
  #     ]) %>
  #
  # Radio buttons drawn as selectable cards, in a <fieldset> with a <legend>. Each card is the
  # radio's <label>, so clicking anywhere on it selects it, and arrow keys move between choices as
  # with any radio group. The checked card gets a primary border and tint. Choices are hashes as
  # above, `[label, value]` pairs, or plain strings. `hint:`, `error:` and `optional:` work as in
  # FormFieldComponent; `aria-describedby` goes on the fieldset and `aria-invalid` on each radio.
  # columns: 1 (default), 2 or 3, from the `sm` breakpoint. HTML attributes go on the <fieldset>.
  class RadioCardGroupComponent < BaseComponent
    FIELDSET = "m-0 p-0 border-0 min-w-0"
    LEGEND = "mb-2 p-0"
    GRID = {1 => "grid gap-2", 2 => "grid gap-2 sm:grid-cols-2", 3 => "grid gap-2 sm:grid-cols-3"}.freeze
    CARD = "flex items-start gap-3 p-4 bg-surface border border-border rounded-ui cursor-pointer transition duration-150 " \
           "hover:border-primary-border has-checked:border-primary has-checked:bg-primary-subtle " \
           "has-focus-visible:ring-4 has-focus-visible:ring-primary/25 " \
           "has-disabled:opacity-50 has-disabled:cursor-default has-disabled:hover:border-border"
    CARD_INVALID = "border-danger"
    RADIO = "mt-1 size-4 shrink-0 accent-primary focus:outline-none"
    TITLE = "block font-medium"
    DESCRIPTION = "block text-sm text-secondary"

    Choice = Struct.new(:value, :label, :description, :disabled, keyword_init: true)

    def initialize(name:, choices:, legend: nil, checked: nil, id: nil, hint: nil, error: nil, optional: false, columns: 1,
      required: false, **html_options)
      super(**html_options)
      @name = name
      @choices = choices.map { |choice| normalize(choice) }
      @legend = legend
      @checked = checked
      @id = id || generated_id("radio-cards")
      @hint = hint
      @error = error.presence
      @optional = optional
      @columns = columns
      @required = required
    end

    def call
      parts = [legend, *messages, grid]
      tag.fieldset(safe_join(parts.compact), **attrs(FIELDSET, id: @id, aria: {describedby: describedby}.compact))
    end

    private

    def messages
      [
        (tag.div(@error, id: "#{@id}-error", class: FormFieldComponent::ERROR) if @error),
        (tag.div(@hint, id: "#{@id}-hint", class: FormFieldComponent::HINT) if @hint)
      ]
    end

    def grid
      tag.div(safe_join(@choices.each_with_index.map { |choice, index| card(choice, index) }),
        class: [Variants.fetch(GRID, @columns, kind: "columns"), ("mt-2" if @error || @hint)])
    end

    def legend
      return unless @legend

      marker = tag.span(@optional.is_a?(String) ? @optional : "(optional)", class: FormFieldComponent::OPTIONAL) if @optional
      tag.legend(safe_join([@legend, marker].compact, " "), class: LEGEND)
    end

    def card(choice, index)
      input_id = "#{@id}-#{index}"
      body = safe_join([radio(choice, input_id), tag.span(card_text(choice))])

      tag.label(body, for: input_id, class: ComponentLibrary2100.merge_classes(CARD, (CARD_INVALID if @error)))
    end

    def radio(choice, input_id)
      tag.input(type: "radio", name: @name, value: choice.value, id: input_id, class: RADIO,
        checked: choice.value.to_s == @checked.to_s && !@checked.nil?, disabled: choice.disabled,
        required: (@required || nil), aria: {invalid: (true if @error)}.compact)
    end

    def card_text(choice)
      safe_join([
        tag.span(choice.label, class: TITLE),
        (tag.span(choice.description, class: DESCRIPTION) if choice.description)
      ].compact)
    end

    def normalize(choice)
      case choice
      when Hash then Choice.new(**choice.to_h.symbolize_keys.slice(:value, :label, :description, :disabled))
      when Array then Choice.new(label: choice[0], value: choice[1], description: choice[2])
      else Choice.new(label: choice.to_s, value: choice.to_s)
      end
    end

    def describedby
      [("#{@id}-error" if @error), ("#{@id}-hint" if @hint)].compact.join(" ").presence
    end
  end
end
