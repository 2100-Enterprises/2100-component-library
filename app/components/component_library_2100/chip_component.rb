module ComponentLibrary2100
  # A value the user chose or filtered by, optionally with a remove control. Badge is for statuses;
  # a Chip is for removable values such as active filters, chosen members or file types. Without
  # `remove:` it is a static <span> (a Tag).
  #
  #   <%= render ChipComponent.new(label: "Draft") %>
  #   <%= render ChipComponent.new(label: "Open", variant: :primary, remove: admin_projects_path) %>
  #   <%= render ChipComponent.new(label: "Ada", remove: {href: member_path(1), method: :delete}) do |chip| %>
  #     <% chip.with_icon { "..." } %>
  #   <% end %>
  #
  # `remove:` takes a URL, or a hash of `href:`, `method:`, `label:` and `params:`. With only an href
  # the control is a link (the server-driven case: the URL is the page without this filter). With a
  # `method:` other than GET it is a small form with a submit button, so the CSRF token is kept.
  # The control is named "Remove <label>"; set `remove: {label:}` to change it.
  #
  # The control is a real link or button, so it is reachable and operable by keyboard with no JS.
  # Its hit area is at least 44px on touch screens even though the X is small.
  class ChipComponent < BaseComponent
    BASE = "inline-flex items-center gap-1 max-w-full ps-3 py-1 text-sm leading-tight border rounded-full"
    STATIC = "pe-3"
    REMOVABLE = "pe-1"
    REMOVE = "#{Variants::TOUCH_TARGET} inline-flex items-center justify-center shrink-0 size-5 p-0 rounded-full border-0 " \
             "bg-transparent text-current cursor-pointer opacity-60 hover:opacity-100 " \
             "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"
    ICON = "inline-flex shrink-0 items-center"

    X = "M.293.293a1 1 0 0 1 1.414 0L8 6.586 14.293.293a1 1 0 1 1 1.414 1.414L9.414 8l6.293 6.293a1 1 0 0 1-1.414 1.414L8 9.414l-6.293 6.293a1 1 0 0 1-1.414-1.414L6.586 8 .293 1.707a1 1 0 0 1 0-1.414z"

    renders_one :icon, ->(**opts, &block) { tag.span(**merge_attrs(opts, ICON, aria: {hidden: true}), &block) }

    def initialize(label: nil, variant: :secondary, remove: nil, **html_options)
      super(**html_options)
      @label = label
      @variant = variant
      @remove = remove.is_a?(Hash) ? remove.symbolize_keys : {href: remove}.compact
    end

    def call
      text = @label || content
      colour = Variants.fetch(Variants::SUBTLE, @variant)
      body = safe_join([icon, tag.span(text, class: "min-w-0 wrap-anywhere"), remove_control(text)].compact)

      tag.span(body, **attrs([BASE, colour, (@remove.empty? ? STATIC : REMOVABLE)]))
    end

    private

    def remove_control(text)
      return if @remove.empty?

      href = @remove.fetch(:href)
      button = {class: REMOVE, aria: {label: @remove[:label] || "Remove #{strip_tags(text.to_s).squish}"}}
      return tag.a(x_icon, href: href, **button) unless remove_by_form?

      button_to(href, method: @remove[:method], params: @remove[:params] || {}, form: {class: "inline-flex m-0"}, **button) { x_icon }
    end

    # A `method:` other than GET needs a form, since a link can only GET.
    def remove_by_form?
      method = @remove[:method]
      method && method.to_s.downcase != "get"
    end

    def x_icon
      tag.svg(tag.path(d: X), viewBox: "0 0 16 16", fill: "currentColor", class: "size-2.5", aria: {hidden: true})
    end
  end
end
