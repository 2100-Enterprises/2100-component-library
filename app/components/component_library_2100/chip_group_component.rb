module ComponentLibrary2100
  # A list of chips, such as the active filters on an admin list. Renders a <ul> with one <li> per
  # chip, and `label:` becomes the list's accessible name.
  #
  #   <%= render ChipGroupComponent.new(label: "Active filters") do |group| %>
  #     <% group.with_chip(label: "Open", remove: projects_path(except: :status)) %>
  #     <% group.with_chip(label: "Ada", variant: :primary, remove: {href: member_path(1), method: :delete}) %>
  #   <% end %>
  #
  # Each chip takes the same arguments as ChipComponent. There is no JavaScript: removing a chip is
  # a link or form submit, so focus is lost on the page load. Have the server redirect back to the
  # page, and let that page move focus to the group's label (or the list) so keyboard and
  # screen reader users land where they were. That part is up to the page.
  class ChipGroupComponent < BaseComponent
    LIST = "flex flex-wrap items-center gap-2 p-0 m-0 list-none"

    renders_many :chips, ->(**opts) { ChipComponent.new(**opts) }

    def initialize(label: nil, **html_options)
      super(**html_options)
      @label = label
    end

    def call
      tag.ul(safe_join(chips.map { |chip| tag.li(chip) }), **attrs(LIST, aria: {label: @label}.compact))
    end
  end
end
