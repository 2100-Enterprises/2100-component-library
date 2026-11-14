module ComponentLibrary2100
  # The multiple-value half of ComboboxComponent (`multiple: true`): a bordered box holding the
  # chips and the text input, and the hidden inputs the form submits. It is rendered by
  # ComboboxComponent, not used on its own.
  class ComboboxTagsComponent < BaseComponent
    BOX = "flex flex-wrap items-center gap-1.5 w-full pointer-coarse:min-h-11 px-2 py-1.5 text-base font-normal bg-surface " \
          "bg-clip-padding border border-border-input rounded-ui transition duration-150 pe-10 " \
          "focus-within:border-primary-border focus-within:ring-4 focus-within:ring-primary/25 " \
          "has-aria-invalid:border-danger has-aria-invalid:focus-within:ring-danger/25"
    INPUT = "flex-1 min-w-32 px-1 py-0.5 text-base text-body bg-transparent border-0 outline-none focus:outline-none " \
            "placeholder:text-secondary"
    CHIPS = "flex flex-wrap gap-1.5 empty:hidden"
    ACTIONS = "input->cl-combobox#input keydown->cl-combobox#keydown blur->cl-combobox#blur"

    # A string, or a `[label, value]` pair, as a `[label, value]` pair of strings.
    def self.pair(item)
      item = Array(item)
      [item.first.to_s, item.last.to_s]
    end

    def initialize(name:, input_id:, listbox_id:, input: {}, values: [], max: nil, label: nil, invalid: false, **_ignored)
      super()
      @name = name
      @input_id = input_id
      @listbox_id = listbox_id
      @input_options = input
      @values = Array(values).map { |item| self.class.pair(item) }
      @max = max
      @label = label
      @invalid = invalid
    end

    def call
      safe_join([tag.div(safe_join([chips, chip_template, input]), class: BOX), values_fields])
    end

    private

    def full? = @max && @values.size >= @max

    # The input has no name, since the values submit through the hidden inputs.
    def input
      options = merge_attrs(@input_options, INPUT, type: :text, id: @input_id, role: "combobox", autocomplete: "off",
        aria: input_aria, data: {cl_combobox_target: "input", action: ACTIONS})
      options[:hidden] = true if full?
      tag.input(**options)
    end

    def input_aria
      named = @input_options.dig(:aria, :label) || @input_options.dig(:aria, :labelledby)
      {autocomplete: "list", haspopup: "listbox", expanded: false, controls: @listbox_id, invalid: (true if @invalid),
       label: (@label unless named)}.compact
    end

    def chips
      tag.div(safe_join(@values.map { |label, value| chip(label, value) }), class: CHIPS, role: "group",
        aria: {label: @label}.compact, data: {cl_combobox_target: "chips"})
    end

    def chip(label, value)
      render(ChipComponent.new(label: label, remove: {button: true, data: {action: "cl-combobox#remove"}},
        data: {cl_combobox_target: "chip", value: value}))
    end

    def chip_template = tag.template(chip("", ""), data: {cl_combobox_target: "template"})

    # An empty field first, then one per value, so submitting with no chips still sends the key.
    def values_fields
      fields = [["", ""], *@values].map { |_, value| tag.input(type: :hidden, name: @name, value: value, autocomplete: "off") }
      tag.div(safe_join(fields), data: {cl_combobox_target: "values"})
    end
  end
end
