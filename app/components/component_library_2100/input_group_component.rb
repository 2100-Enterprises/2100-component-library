module ComponentLibrary2100
  # Bootstrap's input-group: joins a form control with leading/trailing add-ons (text, icons or
  # buttons) into one connected control.
  #
  # <%= render InputGroupComponent.new do |group| %>
  #   <% group.with_prepend { "$" } %>
  #   <% group.with_control do %>
  #     <%= number_field_tag :amount, nil, class: ComponentLibrary2100::InputGroupComponent::CONTROL %>
  #   <% end %>
  #   <% group.with_append { ".00" } %>
  # <% end %>
  #
  # A plain string add-on is wrapped in the styled "input-group-text" span; pass a block that
  # renders a button (e.g. `ui_button`) for a button add-on. The children share borders and only
  # the outer corners are rounded, as in Bootstrap. `size:` is nil, `:sm` or `:lg`. Associating an
  # add-on with the control (`aria-describedby`/`aria-label`) is the caller's job; the add-on span
  # accepts attributes so you can give it an `id:`.
  class InputGroupComponent < BaseComponent
    # Callers put this on their own control so it lines up with the group (flat corners, flex grow).
    CONTROL = "relative flex-auto w-px min-w-0 px-3 py-1.5 text-base font-normal leading-normal text-body bg-surface " \
              "bg-clip-padding border border-border-input rounded-none appearance-none transition duration-150 " \
              "placeholder:text-secondary focus:z-10 focus:outline-none focus:border-primary-border focus:ring-4 focus:ring-primary/25 " \
              "disabled:bg-surface-muted read-only:bg-surface-muted " \
              "aria-invalid:border-danger aria-invalid:focus:border-danger aria-invalid:focus:ring-danger/25"

    TEXT = "inline-flex items-center px-3 text-base font-normal leading-normal text-body text-center whitespace-nowrap " \
           "bg-surface-muted border border-border-input"

    SIZES = {
      sm: "text-sm px-2 py-1",
      lg: "text-lg px-4 py-2"
    }.freeze

    renders_one :control
    renders_many :prepends, ->(**opts, &block) { addon(opts, &block) }
    renders_many :appends, ->(**opts, &block) { addon(opts, &block) }

    def initialize(size: nil, **html_options)
      super(**html_options)
      @size = size
    end

    # Round only the outer corners and collapse the double borders between children, whatever each
    # child element is, with selectors on the group itself.
    GROUP = "flex w-full items-stretch [&>*]:rounded-none [&>*:first-child]:rounded-l-ui [&>*:last-child]:rounded-r-ui " \
            "[&>:not(:first-child)]:-ml-px"

    def call
      tag.div(safe_join([*prepends, control, *appends].compact), **attrs(GROUP))
    end

    private

    # An add-on: wrap plain text in the styled span; leave block content (a button) as given.
    def addon(opts, &block)
      body = capture(&block)
      size_css = @size ? Variants.fetch(SIZES, @size, kind: "size") : nil
      tag.span(body, **merge_attrs(opts, ComponentLibrary2100.merge_classes(TEXT, size_css)))
    end
  end
end
