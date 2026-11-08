module ComponentLibrary2100
  # One suggestion in a Combobox's listbox. The endpoint a Combobox loads renders these inside a
  # Turbo Frame with the combobox's frame id (the `Turbo-Frame` request header), so it never writes
  # ARIA by hand:
  #
  # <%= turbo_frame_tag request.headers["Turbo-Frame"] do %>
  #   <% @people.each do |person| %>
  #     <%= render ComboboxOptionComponent.new(value: person.id, label: person.name) %>
  #   <% end %>
  # <% end %>
  #
  # With groups:
  #
  # <%= render ComboboxOptionComponent::Group.new(label: "Engineering") do %>
  #   <%= render ComboboxOptionComponent.new(value: 1, label: "Ada Lovelace") %>
  # <% end %>
  #
  # `value:` is what the hidden input submits, `label:` what the visible input shows once chosen
  # (default: the value). A block replaces the visible content, for example to show an avatar; the
  # label is still what's filled in. `disabled: true` keeps the option out of keyboard navigation.
  # The `cl-combobox` controller marks the active option with `aria-selected="true"`; it is drawn
  # with an outline and a check mark as well as a fill, so it doesn't rely on colour.
  class ComboboxOptionComponent < BaseComponent
    OPTION = "flex items-center justify-between gap-2 px-3 py-1.5 pointer-coarse:min-h-11 text-body cursor-pointer " \
             "hover:bg-surface-muted aria-selected:bg-primary-subtle aria-selected:text-primary-emphasis " \
             "aria-selected:outline-2 aria-selected:-outline-offset-2 aria-selected:outline-primary " \
             "aria-selected:after:content-['✓'] aria-selected:after:font-semibold aria-disabled:cursor-default aria-disabled:text-secondary"
    GROUP_HEADING = "px-3 py-1 text-sm font-semibold text-secondary"

    def initialize(value:, label: nil, disabled: false, **html_options)
      super(**html_options)
      @value = value
      @label = (label || value).to_s
      @disabled = disabled
    end

    def call
      tag.div(content || @label, **attrs(OPTION, id: generated_id("option"), role: "option", data: {value: @value, label: @label},
        aria: {selected: false, disabled: (true if @disabled)}.compact))
    end

    # A labelled set of options: `role="group"` named by its heading through `aria-labelledby`.
    class Group < BaseComponent
      def initialize(label:, **html_options)
        super(**html_options)
        @label = label
        @heading_id = generated_id("group")
      end

      def call
        tag.div(safe_join([tag.div(@label, id: @heading_id, role: "presentation", class: GROUP_HEADING), content]),
          **attrs(nil, role: "group", aria: {labelledby: @heading_id}))
      end
    end
  end
end
