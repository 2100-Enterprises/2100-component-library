module ComponentLibrary2100
  # A text input with server-side suggestions (PrimeVue's AutoComplete), following the WAI-ARIA 1.2
  # combobox pattern with a list popup.
  #
  # <%= render ComboboxComponent.new(name: "person_id", src: people_path, frame_id: "people",
  #       input: {id: "person", aria: {label: "Person"}}, placeholder: "Search people") %>
  #
  # Typing (after `min_length:` characters and a `delay:` of 250ms) sets the `src` of a Turbo Frame
  # inside the popup to `src?q=<text>`. The endpoint answers with a `<turbo-frame>` of the same id
  # holding ComboboxOptionComponent items (see there); the id is `frame_id:`, and arrives in the
  # `Turbo-Frame` request header. A hidden input holds the chosen `value:`, the visible input shows
  # `text:` (default: the value). `force_selection: true` clears free text and the hidden value on
  # blur unless an option was chosen; otherwise the typed text is the value. The input is named
  # `name:` for forms; with `cl-combobox`, the name moves to the hidden input.
  #
  # Keys: Down and Up move through the options (Down opens a closed list), Enter chooses, Escape
  # closes (a second Escape clears), Alt+Down opens without moving, Alt+Up chooses and closes, and
  # Tab closes and chooses nothing. Home and End keep moving the caret. A polite live region
  # announces "5 results" or "No results" after each load, `aria-busy` marks the listbox while the
  # frame loads, and choosing fires `cl-combobox:select` with `{value, label}` in `detail`.
  #
  # `input:` takes HTML attributes for the visible input (`id:`, `class:`, `aria:`, `required:` ...);
  # the root <div> takes the rest. Give the input an accessible name with a <label for=> (the
  # FormBuilder does) or `aria: {label:}`. `invalid: true` sets `aria-invalid`. `messages:` replaces
  # the live-region texts (`none`, `one`, and `many` with `%{count}`).
  #
  # `multiple: true` is a tags mode: chosen values are ChipComponents (each with a "Remove <value>"
  # button) inside the field before the text input, and the component submits one hidden input per
  # value, named `name:` (`[]` is added when missing), after an empty one so clearing every chip
  # still submits an empty list. `values:` are the initial values (strings, or `[label, value]`
  # pairs), `max:` caps how many there can be, and `allow_free_text: true` lets Enter or a comma turn
  # the typed text into a chip. Choosing a suggestion adds it, Backspace in the empty input removes
  # the last chip, and chosen values aren't suggested again. At `max:` the input is hidden, focus
  # moves to the last chip and a polite live region says "Maximum of 3 reached". Removing a chip
  # returns focus to the input. `label:` names the chip list (`role="group"`) and, unless `input:`
  # names it, the input. `options:` (strings or `[label, value]` pairs) are static suggestions,
  # filtered in the browser, for when there's no `src:`. The live region announces "Ada added" and
  # "Ada removed"; `messages:` also takes `added`, `removed` and `max`.
  #
  # <%= render ComboboxComponent.new(name: "post[collaborators][]", multiple: true, max: 3,
  #       allow_free_text: true, values: %w[ada grace], label: "Collaborators", src: nil) %>
  #
  # Without JavaScript or Turbo the input stays a plain text input named `name:` inside the host
  # form and submits what was typed. The component doesn't wrap its own <form>, since forms can't
  # nest.
  class ComboboxComponent < BaseComponent
    ROOT = "relative"
    LISTBOX = "absolute left-0 right-0 top-full z-20 mt-1 max-h-60 overflow-y-auto py-1 text-base bg-surface " \
              "border border-border-translucent rounded-ui shadow-lg aria-busy:opacity-70"
    INDICATOR = "pointer-events-none absolute inset-y-0 right-3 flex items-center text-secondary"
    SPINNER = "size-4 rounded-full border-2 border-current border-r-transparent animate-spin motion-reduce:animate-none"
    MESSAGES = {none: "No results", one: "1 result", many: "%{count} results",
                added: "%{value} added", removed: "%{value} removed", max: "Maximum of %{max} reached"}.freeze
    attr_reader :frame_id

    TAGS_OPTIONS = %i[max allow_free_text values label].freeze

    def initialize(name:, src: nil, value: nil, text: nil, frame_id: nil, min_length: 1, delay: 250, force_selection: false,
      invalid: false, input: {}, listbox_label: "Suggestions", messages: {}, multiple: false, options: [], **html_options)
      @tags = html_options.extract!(*TAGS_OPTIONS)
      super(**html_options)
      @multiple = multiple
      @options = options
      @name = name
      @value = value
      @text = text || value
      @settings = {src: src, min_length: min_length, delay: delay, force_selection: force_selection}
      @invalid = invalid
      @input_options = input.to_h.symbolize_keys
      @listbox_label = listbox_label
      @messages = MESSAGES.merge(messages.to_h.symbolize_keys)
      @id = html_options[:id] || generated_id("combobox")
      @frame_id = frame_id || "#{@id}-options"
    end

    def call
      tag.div(safe_join([field, indicator, listbox, status, limit_status]), **attrs(ROOT, data: controller_data))
    end

    private

    # Multiple mode submits an array, so the name ends in `[]`.
    def list_name = (@multiple && !@name.to_s.end_with?("[]")) ? "#{@name}[]" : @name

    def static_options = Array(@options).map { |item| ComboboxTagsComponent.pair(item) }

    # The input and its hidden value, or in multiple mode the chips, input and hidden values.
    def field
      return safe_join([input, hidden]) unless @multiple

      render(ComboboxTagsComponent.new(name: list_name, input: @input_options, input_id: input_id, listbox_id: listbox_id,
        invalid: @invalid, **@tags))
    end

    def controller_data
      {controller: "cl-combobox", cl_combobox_src_value: @settings[:src], cl_combobox_min_length_value: @settings[:min_length],
       cl_combobox_delay_value: @settings[:delay], cl_combobox_force_selection_value: @settings[:force_selection],
       cl_combobox_none_message_value: @messages[:none], cl_combobox_one_message_value: @messages[:one],
       cl_combobox_many_message_value: @messages[:many], **tags_data}
    end

    def tags_data
      return {} unless @multiple

      {cl_combobox_multiple_value: true, cl_combobox_max_value: @tags[:max], cl_combobox_allow_free_text_value: @tags[:allow_free_text],
       cl_combobox_added_message_value: @messages[:added], cl_combobox_removed_message_value: @messages[:removed],
       cl_combobox_max_message_value: @messages[:max]}
    end

    def limit_status
      return unless @multiple

      tag.div(class: "sr-only", role: "status", aria: {live: "polite", atomic: true}, data: {cl_combobox_target: "limit"})
    end

    def input_id = @input_options[:id] || "#{@id}-input"
    def listbox_id = "#{@id}-listbox"

    def input
      options = merge_attrs(@input_options, [FormFieldComponent::CONTROL, "pr-10"],
        type: :text, id: input_id, name: @name, value: @text, role: "combobox", autocomplete: "off",
        aria: {autocomplete: "list", haspopup: "listbox", expanded: false, controls: listbox_id, invalid: (true if @invalid)}.compact,
        data: {cl_combobox_target: "input", action: "input->cl-combobox#input keydown->cl-combobox#keydown blur->cl-combobox#blur"})
      tag.input(**options)
    end

    # Holds the value. It has no name until `cl-combobox` connects, so without JavaScript the
    # visible input submits instead.
    def hidden
      tag.input(type: :hidden, id: "#{@id}-value", value: @value, data: {cl_combobox_target: "hidden"})
    end

    def indicator
      tag.span(tag.span(class: SPINNER), class: INDICATOR, hidden: true, aria: {hidden: true}, data: {cl_combobox_target: "indicator"})
    end

    def listbox
      tag.div(frame, id: listbox_id, role: "listbox", class: LISTBOX, hidden: true, aria: {label: @listbox_label, busy: false}, data: {
        cl_combobox_target: "listbox", action: "mousedown->cl-combobox#hold click->cl-combobox#choose mouseover->cl-combobox#hover"
      })
    end

    def frame
      tag.turbo_frame(safe_join(static_options.map { |label, value| render(ComboboxOptionComponent.new(value: value, label: label)) }), id: frame_id, data: {
        cl_combobox_target: "frame",
        action: "turbo:before-fetch-request->cl-combobox#loading turbo:frame-load->cl-combobox#loaded turbo:fetch-request-error->cl-combobox#failed"
      })
    end

    def status
      tag.div(class: "sr-only", role: "status", aria: {live: "polite", atomic: true}, data: {cl_combobox_target: "status"})
    end
  end
end
