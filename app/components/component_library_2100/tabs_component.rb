module ComponentLibrary2100
  # <%= render TabsComponent.new(style: :pills) do |tabs| %>
  #   <% tabs.with_tab(title: "Profile", active: true) { "Profile content" } %>
  #   <% tabs.with_tab(title: "Billing") { "Billing content" } %>
  #   <% tabs.with_tab(title: "Archived", disabled: true) { "Unavailable" } %>
  # <% end %>
  #
  # Follows the WAI-ARIA tabs pattern (arrow keys, Home/End, one tab stop). The first enabled tab
  # opens unless you mark one `active: true`. HTML attributes go on the outer element.
  # style: :tabs (default) or :pills.
  class TabsComponent < BaseComponent
    LIST = {
      tabs: "flex flex-wrap pl-0 mb-0 list-none border-b border-border",
      pills: "flex flex-wrap gap-1 pl-0 mb-0 list-none"
    }.freeze

    TAB = {
      tabs: "block px-4 py-2 -mb-px text-primary bg-transparent border border-transparent rounded-t-ui cursor-pointer " \
            "hover:border-border-subtle hover:border-b-border aria-selected:text-body-muted aria-selected:bg-surface " \
            "aria-selected:border-border aria-selected:border-b-surface",
      pills: "block px-4 py-2 text-primary bg-transparent border-0 rounded-ui cursor-pointer " \
             "aria-selected:text-primary-on aria-selected:bg-primary"
    }.freeze

    COMMON = "disabled:pointer-events-none disabled:text-secondary focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"

    renders_many :tabs, "ComponentLibrary2100::TabPanelComponent"

    def initialize(style: :tabs, **html_options)
      super(**html_options)
      @style = style
    end

    def before_render
      tabs.find(&:enabled?)&.activate! unless tabs.any?(&:active?)
    end

    def call
      tag.div(safe_join([tablist, safe_join(tabs)]), **attrs(nil, data: {controller: "cl-tabs"}))
    end

    private

    def tablist
      tag.div(safe_join(tabs.map { |tab| button(tab) }), role: "tablist", class: Variants.fetch(LIST, @style, kind: "style"),
        data: {action: "keydown->cl-tabs#navigate"})
    end

    def button(tab)
      tag.button(tab.title, type: :button, role: "tab", id: tab.tab_id, disabled: tab.disabled?,
        class: ComponentLibrary2100.merge_classes(Variants.fetch(TAB, @style, kind: "style"), COMMON),
        tabindex: (tab.active? ? 0 : -1),
        aria: {selected: tab.active?, controls: tab.panel_id},
        data: {cl_tabs_target: "tab", action: "click->cl-tabs#select"})
    end
  end
end
