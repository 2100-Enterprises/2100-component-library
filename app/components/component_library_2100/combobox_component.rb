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
  # Without JavaScript or Turbo the input stays a plain text input named `name:` inside the host
  # form and submits what was typed. The component doesn't wrap its own <form>, since forms can't
  # nest.
  class ComboboxComponent < BaseComponent
    ROOT = "relative"
    LISTBOX = "absolute left-0 right-0 top-full z-20 mt-1 max-h-60 overflow-y-auto py-1 text-base bg-surface " \
              "border border-border-translucent rounded-ui shadow-lg aria-busy:opacity-70"
    INDICATOR = "pointer-events-none absolute inset-y-0 right-3 flex items-center text-secondary"
    SPINNER = "size-4 rounded-full border-2 border-current border-r-transparent animate-spin motion-reduce:animate-none"
    MESSAGES = {none: "No results", one: "1 result", many: "%{count} results"}.freeze

    attr_reader :frame_id

    def initialize(name:, src:, value: nil, text: nil, frame_id: nil, min_length: 1, delay: 250, force_selection: false,
      invalid: false, input: {}, listbox_label: "Suggestions", messages: {}, **html_options)
      super(**html_options)
      @name = name
      @src = src
      @value = value
      @text = text || value
      @min_length = min_length
      @delay = delay
      @force_selection = force_selection
      @invalid = invalid
      @input_options = input.to_h.symbolize_keys
      @listbox_label = listbox_label
      @messages = MESSAGES.merge(messages.to_h.symbolize_keys)
      @id = html_options[:id] || generated_id("combobox")
      @frame_id = frame_id || "#{@id}-options"
    end

    def call
      tag.div(safe_join([input, hidden, indicator, listbox, status]), **attrs(ROOT, data: {
        controller: "cl-combobox",
        cl_combobox_src_value: @src,
        cl_combobox_min_length_value: @min_length,
        cl_combobox_delay_value: @delay,
        cl_combobox_force_selection_value: @force_selection,
        cl_combobox_none_message_value: @messages[:none],
        cl_combobox_one_message_value: @messages[:one],
        cl_combobox_many_message_value: @messages[:many]
      }))
    end

    private

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
      tag.turbo_frame(id: frame_id, data: {
        cl_combobox_target: "frame",
        action: "turbo:before-fetch-request->cl-combobox#loading turbo:frame-load->cl-combobox#loaded turbo:fetch-request-error->cl-combobox#failed"
      })
    end

    def status
      tag.div(class: "sr-only", role: "status", aria: {live: "polite", atomic: true}, data: {cl_combobox_target: "status"})
    end
  end
end
