module ComponentLibrary2100
  # <%= render AccordionComponent.new do |accordion| %>
  #   <% accordion.with_item(title: "First", open: true) { "Opens first." } %>
  #   <% accordion.with_item(title: "Second") { "Opening this closes the first." } %>
  # <% end %>
  #
  # Built on <details>, so it needs no JavaScript and works from the keyboard. Items share a
  # `name`, which makes the browser close the others; pass `always_open: true` to let several stay open.
  class AccordionComponent < BaseComponent
    renders_many :items, ->(title:, open: false, **opts) {
      AccordionItemComponent.new(title: title, open: open, group: @group, **opts)
    }

    def initialize(always_open: false, **html_options)
      super(**html_options)
      @group = always_open ? nil : generated_id("accordion")
    end

    def call
      tag.div(safe_join(items), **attrs("rounded-ui"))
    end
  end
end
