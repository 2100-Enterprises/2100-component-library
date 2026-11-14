module ComponentLibrary2100
  # <%= render NavbarComponent.new(label: "Main", expand: :lg, theme: :dark) do |navbar| %>
  #   <% navbar.with_brand(href: "/") { "2100" } %>
  #   <% navbar.with_item("Projects", href: "/projects", active: true) %>
  #   <% navbar.with_item("Clients", href: "/clients") %>
  #   <% navbar.with_menu("Content") do |menu| %>
  #     <% menu.with_item("Planned posts", href: "/posts", active: true) %>
  #     <% menu.with_item("Drafts", href: "/drafts") %>
  #   <% end %>
  #   <% navbar.with_actions do %>
  #     <%= ui_dropdown(placement: "bottom-end") { |menu| ... } %>
  #   <% end %>
  # <% end %>
  #
  # A Bootstrap-style navbar in a <nav> landmark (`label:` names it). `active: true` sets
  # `aria-current="page"` on an item. Below the `expand:` breakpoint (:sm, :md, :lg default, :xl,
  # :xxl) the items move into an OffcanvasComponent opened by a menu button; `expand: true` never
  # collapses and `expand: false` always does. `actions` stay in the bar at every width, so an
  # account dropdown is always reachable. theme: :light (default) or :dark, from the light/dark
  # tokens, or :surface, from the surface and body tokens, which follows dark mode. `menu_label:`
  # `with_menu(label, active: false, **opts) { |menu| menu.with_item(...) }` adds a group of links; items
  # and menus render in the order they are added. In the bar a menu is a DropdownComponent whose trigger
  # looks like a link (`opts` go on the dropdown) and carries `data-current` when `active:` or any child
  # is active; below the breakpoint it is a labelled list in the panel, with no dropdown. `menu_label:`
  # names the menu button and titles the panel; `placement:` docks the panel (:end default). HTML
  # attributes go on the <nav>.
  class NavbarComponent < BaseComponent
    BASE = "relative flex flex-wrap items-center gap-x-4 gap-y-2 px-4 py-2"
    LIST = "flex m-0 p-0 list-none"
    ACTIONS = "flex items-center gap-2 ml-auto"
    LINK_BASE = "block px-2 py-2 no-underline rounded-ui focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25 pointer-coarse:py-2.5"
    TRIGGER_CURRENT = "data-[current]:underline data-[current]:underline-offset-4"
    GROUP_LABEL = "block px-2 py-1 text-sm"
    BRAND_BASE = "py-1 text-xl whitespace-nowrap no-underline"
    TOGGLER_BASE = "px-3 py-1 text-xl leading-none no-underline bg-transparent rounded-ui focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"
    ICON = "M2.5 12a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5m0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5m0-4a.5.5 0 0 1 .5-.5h10a.5.5 0 0 1 0 1H3a.5.5 0 0 1-.5-.5"

    THEMES = {
      light: {
        bar: "bg-light text-light-on",
        link: "text-light-on/55 hover:text-light-on/70 aria-[current=page]:text-light-on/90",
        current: "data-[current]:text-light-on/90",
        group: "text-light-on/55",
        brand: "text-light-on/90 hover:text-light-on/90",
        toggler: "text-light-on/55 border-light-on/10 hover:text-light-on/55",
        close: false
      },
      dark: {
        bar: "bg-dark text-dark-on",
        link: "text-dark-on/55 hover:text-dark-on/75 aria-[current=page]:text-dark-on",
        current: "data-[current]:text-dark-on",
        group: "text-dark-on/55",
        brand: "text-dark-on hover:text-dark-on",
        toggler: "text-dark-on/55 border-dark-on/10 hover:text-dark-on/55",
        close: true
      },
      # The page's own surface and text, so the bar follows dark mode.
      surface: {
        bar: "bg-surface text-body",
        link: "text-body-muted hover:text-body aria-[current=page]:text-body",
        current: "data-[current]:text-body",
        group: "text-body-muted",
        brand: "text-body hover:text-body",
        toggler: "text-body-muted border-border hover:text-body",
        close: false
      }
    }.freeze

    # Inline links show from the breakpoint up; the menu button shows below it.
    INLINE = {
      true => "flex-row",
      false => "hidden",
      sm: "hidden sm:flex sm:flex-row",
      md: "hidden md:flex md:flex-row",
      lg: "hidden lg:flex lg:flex-row",
      xl: "hidden xl:flex xl:flex-row",
      xxl: "hidden 2xl:flex 2xl:flex-row"
    }.freeze

    TOGGLER = {
      false => "inline-block",
      sm: "inline-block sm:hidden",
      md: "inline-block md:hidden",
      lg: "inline-block lg:hidden",
      xl: "inline-block xl:hidden",
      xxl: "inline-block 2xl:hidden"
    }.freeze

    renders_one :brand, ->(label = nil, href: nil, **opts, &block) {
      text = block ? capture(&block) : label
      css = [BRAND_BASE, theme[:brand]]
      href ? tag.a(text, **merge_attrs(opts, css, href: href)) : tag.span(text, **merge_attrs(opts, css))
    }

    # The group object `with_menu` yields. It only collects its links; the navbar renders them, once
    # as a dropdown and once as a labelled list.
    class Menu < BaseComponent
      Item = Struct.new(:text, :href, :active, :opts)

      attr_reader :label, :menu_items

      def initialize(label, active: false, **opts)
        super()
        @label = label
        @active = active
        @opts = opts
        @menu_items = []
      end

      def with_item(label = nil, href:, active: false, **opts, &block)
        @menu_items << Item.new(block ? capture(&block) : label, href, active, opts)
        nil
      end

      def current? = @active || @menu_items.any?(&:active)

      # Options for the dropdown, without the id and placement the navbar sets itself.
      def dropdown_options = @opts.except(:id, :placement)

      def placement = @opts.fetch(:placement, "bottom-start")

      def base_id = @base_id ||= @opts[:id] || generated_id("navbar-group")

      def call = (content; "")
    end

    renders_many :entries, types: {
      item: {
        as: :item,
        renders: ->(label = nil, href:, active: false, **opts, &block) {
          text = block ? capture(&block) : label
          tag.li(tag.a(text, **merge_attrs(opts, [LINK_BASE, theme[:link]], href: href, aria: {current: ("page" if active)}.compact)))
        }
      },
      menu: {
        as: :menu,
        renders: ->(label, active: false, **opts) { Menu.new(label, active: active, **opts) }
      }
    }

    renders_one :actions, ->(**opts, &block) { tag.div(**merge_attrs(opts, nil), &block) }

    def initialize(label: nil, expand: :lg, theme: :light, menu_label: "Menu", placement: :end, **html_options)
      super(**html_options)
      @label = label
      @expand = expand.is_a?(String) ? expand.to_sym : expand
      @theme = theme.to_sym
      @menu_label = menu_label
      @placement = placement
      Variants.fetch(INLINE, @expand, kind: "expand option")
      Variants.fetch(THEMES, @theme, kind: "theme")
    end

    def call
      tag.nav(safe_join([brand, inline_list, end_group].compact), **attrs([BASE, theme[:bar]], aria: {label: @label}.compact))
    end

    private

    def theme = THEMES.fetch(@theme)

    def collapses? = @expand != true && entries?

    def inline_list
      return unless entries?

      tag.ul(safe_join(entries.map { |entry| bar_entry(entry) }), class: [LIST, "items-center", INLINE.fetch(@expand)])
    end

    def menu?(entry) = entry.respond_to?(:menu_items)

    def bar_entry(entry)
      return entry unless menu?(entry)

      entry.to_s
      dropdown = DropdownComponent.new(**entry.dropdown_options, placement: entry.placement, id: entry.base_id)
      tag.li(render(dropdown) { |menu| fill_dropdown(menu, entry) })
    end

    def fill_dropdown(menu, entry)
      menu.with_trigger(**menu_trigger_options(entry)) { entry.label }
      entry.menu_items.each do |item|
        menu.with_item(item.text, **item.opts.merge(href: item.href, active: item.active, aria: current_aria(item)))
      end
    end

    def menu_trigger_options(entry)
      {variant: :link, class: [LINK_BASE, theme[:link], TRIGGER_CURRENT, theme[:current]], data: {current: (true if entry.current?)}.compact}
    end

    def panel_entry(entry)
      return entry unless menu?(entry)

      entry.to_s
      label_id = "#{entry.base_id}-label"
      tag.li(safe_join([tag.span(entry.label, id: label_id, class: [GROUP_LABEL, theme[:group]]), panel_group(entry, label_id)]))
    end

    def panel_group(entry, label_id)
      links = entry.menu_items.map { |item| tag.li(panel_link(item)) }
      tag.ul(safe_join(links), class: [LIST, "flex-col"], aria: {labelledby: label_id})
    end

    def panel_link(item)
      tag.a(item.text, **merge_attrs(item.opts, [LINK_BASE, theme[:link]], href: item.href, aria: current_aria(item)))
    end

    def current_aria(item) = {current: ("page" if item.active)}.compact

    def end_group
      return unless actions? || collapses?

      tag.div(safe_join([actions, (offcanvas if collapses?)].compact), class: ACTIONS)
    end

    def offcanvas
      panel = OffcanvasComponent.new(title: @menu_label, placement: @placement, id: menu_id, class: theme[:bar], close: {white: theme[:close]})
      toggler = toggler_options
      icon = toggler_icon
      list = panel_list

      render(panel) do |offcanvas|
        offcanvas.with_trigger(**toggler) { icon }
        list
      end
    end

    def panel_list = tag.ul(safe_join(entries.map { |entry| panel_entry(entry) }), class: [LIST, "flex-col"])

    def toggler_options
      {
        variant: :link,
        class: [TOGGLER_BASE, theme[:toggler], TOGGLER.fetch(@expand)],
        aria: {label: @menu_label, controls: menu_id, expanded: false},
        data: {cl_dialog_target: "trigger"}
      }
    end

    def toggler_icon
      tag.svg(tag.path(d: ICON), viewBox: "0 0 16 16", fill: "currentColor", class: "size-[1.5em] align-middle", aria: {hidden: true})
    end

    def menu_id = @menu_id ||= html_options[:id] ? "#{html_options[:id]}-menu" : generated_id("navbar-menu")
  end
end
