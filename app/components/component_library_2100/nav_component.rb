module ComponentLibrary2100
  # <%= render NavComponent.new(style: :pills, label: "Account") do |nav| %>
  #   <% nav.with_item("Profile", href: "/profile", active: true) %>
  #   <% nav.with_item("Billing", href: "/billing") %>
  #   <% nav.with_item("Archived", href: "/archived", disabled: true) %>
  # <% end %>
  #
  # Tabs or pills made of links, for moving between pages. For tabs that switch panels on the
  # same page, use TabsComponent, which this matches visually. `active: true` sets
  # `aria-current="page"`. `label:` wraps the list in a <nav> landmark with that name.
  # style: :tabs (default) or :pills. `fill: true` stretches items to share the width,
  # `justified: true` also makes them equal widths. HTML attributes go on the <ul>.
  class NavComponent < BaseComponent
    # Same utilities as TabsComponent::TAB, keyed on aria-current instead of aria-selected.
    LINK = {
      tabs: "block px-4 py-2 -mb-px text-primary no-underline bg-transparent border border-transparent rounded-t-ui " \
            "hover:border-border-subtle hover:border-b-border aria-[current=page]:text-body-muted aria-[current=page]:bg-white " \
            "aria-[current=page]:border-border aria-[current=page]:border-b-white",
      pills: "block px-4 py-2 text-primary no-underline bg-transparent border-0 rounded-ui " \
             "aria-[current=page]:text-primary-on aria-[current=page]:bg-primary"
    }.freeze

    COMMON = "aria-disabled:pointer-events-none aria-disabled:text-secondary focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"
    FILL = "flex-auto text-center"
    JUSTIFIED = "basis-0 grow text-center"

    renders_many :items, ->(label = nil, href:, active: false, disabled: false, **opts, &block) {
      text = block ? capture(&block) : label
      aria = {current: ("page" if active), disabled: (true if disabled)}.compact

      link = tag.a(text, **merge_attrs(opts, [Variants.fetch(LINK, @style, kind: "style"), COMMON],
        href: href, aria: aria, tabindex: (-1 if disabled)))
      tag.li(link, class: item_css)
    }

    def initialize(style: :tabs, label: nil, fill: false, justified: false, **html_options)
      super(**html_options)
      @style = style.to_sym
      @label = label
      @fill = fill
      @justified = justified
    end

    def call
      list = tag.ul(safe_join(items), **attrs(Variants.fetch(TabsComponent::LIST, @style, kind: "style")))
      @label ? tag.nav(list, aria: {label: @label}) : list
    end

    private

    def item_css
      return JUSTIFIED if @justified

      FILL if @fill
    end
  end
end
