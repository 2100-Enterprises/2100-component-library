module ComponentLibrary2100
  # <%= render CardComponent.new(class: "w-72") do |card| %>
  #   <% card.with_header { "Featured" } %>
  #   <% card.with_image_top(src: image_path("hero.jpg"), alt: "") %>
  #   <h5 class="mb-2 text-xl font-medium">Title</h5>
  #   <p>Body copy goes straight in; it is wrapped in the card body for you.</p>
  #   <% card.with_footer { "2 days ago" } %>
  # <% end %>
  #
  # Pass `body: false` when the content should sit edge to edge (a ListGroup or Table).
  class CardComponent < BaseComponent
    BASE = "relative flex flex-col min-w-0 break-words bg-white bg-clip-border border border-black/[.125] rounded-ui"
    BODY = "flex-auto p-4"
    HEADER = "px-4 py-3 mb-0 bg-black/[.03] border-b border-black/[.125] first:rounded-t-[calc(var(--radius-ui)-1px)]"
    FOOTER = "px-4 py-3 bg-black/[.03] border-t border-black/[.125] last:rounded-b-[calc(var(--radius-ui)-1px)]"
    IMAGE = "w-full"

    # Header, footer and images accept the usual HTML attributes, including `class:`.
    renders_one :header, ->(**opts, &block) { tag.div(**merge_attrs(opts, HEADER), &block) }
    renders_one :footer, ->(**opts, &block) { tag.div(**merge_attrs(opts, FOOTER), &block) }
    renders_one :image_top, ->(src:, alt: "", **opts) {
      tag.img(src: src, alt: alt, **merge_attrs(opts, [IMAGE, "rounded-t-[calc(var(--radius-ui)-1px)]"]))
    }
    renders_one :image_bottom, ->(src:, alt: "", **opts) {
      tag.img(src: src, alt: alt, **merge_attrs(opts, [IMAGE, "rounded-b-[calc(var(--radius-ui)-1px)]"]))
    }

    def initialize(body: true, **html_options)
      super(**html_options)
      @body = body
    end

    erb_template <<~ERB
      <%= tag.div(**attrs(BASE)) do %>
        <%= header if header? %>
        <%= image_top if image_top? %>
        <% if @body %>
          <%= tag.div(content, class: BODY) %>
        <% else %>
          <%= content %>
        <% end %>
        <%= image_bottom if image_bottom? %>
        <%= footer if footer? %>
      <% end %>
    ERB
  end
end
