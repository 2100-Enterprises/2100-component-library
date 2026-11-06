module ComponentLibrary2100
  # <%= render PaginationComponent.new(size: :sm, aria: { label: "Search results" }) do |pages| %>
  #   <% pages.with_item("Previous", href: "?page=1") %>
  #   <% pages.with_item("2", href: "?page=2", active: true) %>
  #   <% pages.with_item("Next", disabled: true) %>
  # <% end %>
  class PaginationComponent < BaseComponent
    LIST = "flex pl-0 m-0 list-none"
    ITEM = "not-first:-ml-px first:*:rounded-s-ui last:*:rounded-e-ui"
    LINK = "relative block text-primary bg-white border border-[#dee2e6] no-underline " \
           "hover:z-[2] hover:text-[#0a58ca] hover:bg-[#e9ecef] focus:z-[3] focus:ring-4 focus:ring-primary/25 focus:outline-none"
    ACTIVE = "z-[3] text-primary-on bg-primary border-primary hover:text-primary-on hover:bg-primary"
    DISABLED = "pointer-events-none text-secondary bg-white border-[#dee2e6]"
    SIZES = {
      sm: "px-2 py-1 text-sm",
      md: "px-3 py-1.5 text-base",
      lg: "px-6 py-3 text-xl"
    }.freeze

    # Items without an `href:`, or marked active or disabled, render as <span> instead of <a>.
    renders_many :items, ->(label = nil, href: nil, active: false, disabled: false, **opts, &block) {
      text = block ? capture(&block) : label
      css = [LINK, size_classes, (ACTIVE if active), (DISABLED if disabled)]
      state = {aria: {current: (:page if active), disabled: (true if disabled)}.compact}

      link =
        if href && !active && !disabled
          tag.a(text, href: href, class: ComponentLibrary2100.merge_classes(css))
        else
          tag.span(text, class: ComponentLibrary2100.merge_classes(css), **state)
        end

      tag.li(link, **merge_attrs(opts, ITEM))
    }

    def initialize(size: :md, **html_options)
      super(**html_options)
      @size = size
    end

    def call
      tag.nav(tag.ul(safe_join(items), class: LIST), **attrs(nil, aria: {label: "Pagination"}))
    end

    private

    def size_classes
      Variants.fetch(SIZES, @size, kind: "size")
    end
  end
end
