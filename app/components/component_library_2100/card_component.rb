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
  #
  # ## Animation variants
  #
  # Add hover animations using Tailwind's transition and transform utilities:
  #
  # ```erb
  # <%= ui_card class: "hover:scale-[1.02] hover:shadow-lg transition-transform duration-200 ease-out" %>
  # ```
  #
  # The library provides these animation presets:
  # - `:pop` - Subtle scale up on hover with shadow
  # - `:lift` - Translate Y with shadow on hover
  # - `:fade` - Opacity transition on hover
  class CardComponent < BaseComponent
    BASE = "relative flex flex-col min-w-0 break-words bg-surface bg-clip-border border border-border-translucent rounded-ui"
    BODY = "flex-auto p-4"
    HEADER = "px-4 py-3 mb-0 bg-surface-tint border-b border-border-translucent first:rounded-t-[calc(var(--radius-ui)-1px)]"
    FOOTER = "px-4 py-3 bg-surface-tint border-t border-border-translucent last:rounded-b-[calc(var(--radius-ui)-1px)]"
    IMAGE = "w-full"

    # Animation variants for hover effects
    ANIMATIONS = {
      pop: "transition-transform duration-200 ease-out hover:scale-[1.02] hover:shadow-lg",
      lift: "transition-transform duration-200 ease-out hover:-translate-y-1 hover:shadow-lg",
      fade: "transition-opacity duration-200 ease-out hover:opacity-90"
    }.freeze

    # Header, footer and images accept the usual HTML attributes, including `class:`.
    renders_one :header, ->(**opts, &block) { tag.div(**merge_attrs(opts, HEADER), &block) }
    renders_one :footer, ->(**opts, &block) { tag.div(**merge_attrs(opts, FOOTER), &block) }
    renders_one :image_top, ->(src:, alt: "", **opts) {
      tag.img(src: src, alt: alt, **merge_attrs(opts, [IMAGE, "rounded-t-[calc(var(--radius-ui)-1px)]"]))
    }
    renders_one :image_bottom, ->(src:, alt: "", **opts) {
      tag.img(src: src, alt: alt, **merge_attrs(opts, [IMAGE, "rounded-b-[calc(var(--radius-ui)-1px)]"]))
    }

    def initialize(body: true, animation: nil, **html_options)
      super(**html_options)
      @body = body
      @animation = animation.to_sym if animation
    end

    def call
      tag.div(**attrs(css)) do
        concat(header if header?)
        concat(image_top if image_top?)
        if @body
          concat(tag.div(content, class: BODY))
        else
          concat(content)
        end
        concat(image_bottom if image_bottom?)
        concat(footer if footer?)
      end
    end

    private

    def css
      [BASE, animation_class]
    end

    def animation_class
      return if @animation.nil?
      Variants.fetch(ANIMATIONS, @animation, kind: "animation variant") + " motion-reduce:transition-none"
    end
  end
end
