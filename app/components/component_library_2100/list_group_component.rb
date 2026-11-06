module ComponentLibrary2100
  # <%= render ListGroupComponent.new do |list| %>
  #   <% list.with_item { "Plain item" } %>
  #   <% list.with_item(active: true) { "Active" } %>
  #   <% list.with_item(variant: :danger) { "Danger" } %>
  # <% end %>
  #
  # If any item has `href:` (or `action: true`) the group renders as a <div> of
  # <a>/<button> items; otherwise a <ul>/<ol> of <li>. Don't mix the two.
  class ListGroupComponent < BaseComponent
    BASE = "flex flex-col pl-0 mb-0 rounded-ui"
    FLUSH = "rounded-none *:rounded-none! *:border-x-0"
    NUMBERED = "list-decimal list-inside"

    renders_many :items, "ComponentLibrary2100::ListGroupItemComponent"

    def initialize(flush: false, numbered: false, **html_options)
      super(**html_options)
      @flush = flush
      @numbered = numbered
    end

    def call
      tag.public_send(container, content_with_items, **attrs([BASE, (FLUSH if @flush), (NUMBERED if @numbered)]))
    end

    private

    def content_with_items
      safe_join(items)
    end

    def container
      return :div if items.any?(&:action?)

      @numbered ? :ol : :ul
    end
  end
end
