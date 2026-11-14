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
  # Pass `animation:` for a hover effect: `:pop` (scale up with a shadow), `:lift`
  # (raise with a shadow) or `:fade` (dim slightly). Each one is switched off when
  # the visitor prefers reduced motion.
  #
  # <%= ui_card animation: :pop do %>
  #   ...
  # <% end %>
  #
  # `card.with_media(aspect:) { ... }` renders any top content (a <video>, a map, a placeholder) in a
  # box with a fixed aspect ratio, clipped to the card's rounded top corners. `aspect:` is `:video`
  # (16/9), `:square`, `:auto` (the content's own height, the default) or a ratio string such as
  # "4/3". An <img> or <video> child is sized to fill the box (`object-cover`). It takes the place of
  # `image_top`; use one or the other.
  #
  # <%= ui_card do |card| %>
  #   <% card.with_media(aspect: :video) { tag.video(src: video_path("clip.mp4"), controls: true) } %>
  #   ...
  # <% end %>
  #
  # `href:` with `link_label:` makes the whole card one link (the stretched-link technique). The card
  # renders a single <a> that covers it, named by `link_label:` (required, and best worded like the
  # card's title, since the text inside the card is then not separately clickable). The link has the
  # focus ring, and the card gets a ring too while the link has keyboard focus. Controls inside the
  # card that must stay clickable (a button, another link, a menu) opt in with `relative z-10`:
  #
  # <%= ui_card href: post_path(post), link_label: post.title do |card| %>
  #   <h5><%= post.title %></h5>
  #   <%= ui_button "Archive", href: archive_path(post), class: "relative z-10" %>
  # <% end %>
  #
  # Never put a link or button inside the card without that, and never nest a link in `href:`'s: the
  # card's <a> is empty, so there is no <a> inside an <a>.
  class CardComponent < BaseComponent
    BASE = "relative flex flex-col min-w-0 break-words bg-surface bg-clip-border border border-border-translucent rounded-ui"
    BODY = "flex-auto p-4"
    HEADER = "px-4 py-3 mb-0 bg-surface-tint border-b border-border-translucent first:rounded-t-[calc(var(--radius-ui)-1px)]"
    FOOTER = "px-4 py-3 bg-surface-tint border-t border-border-translucent last:rounded-b-[calc(var(--radius-ui)-1px)]"
    IMAGE = "w-full"
    MEDIA = "overflow-hidden rounded-t-[calc(var(--radius-ui)-1px)] [&>img]:size-full [&>img]:object-cover [&>video]:size-full [&>video]:object-cover"
    ASPECTS = {video: "aspect-video", square: "aspect-square", auto: nil}.freeze
    RATIO = %r{\A\d+(\.\d+)?\s*/\s*\d+(\.\d+)?\z}
    LINK = "absolute inset-0 z-0 rounded-ui focus-visible:outline-none"
    LINKED = "transition-shadow hover:shadow-md has-[a:focus-visible]:ring-2 has-[a:focus-visible]:ring-primary has-[a:focus-visible]:ring-offset-2"
    ANIMATION = "duration-200 ease-out motion-reduce:transition-none"
    ANIMATIONS = {
      pop: "transition-transform hover:scale-[1.02] hover:shadow-lg",
      lift: "transition-transform hover:-translate-y-1 hover:shadow-lg",
      fade: "transition-opacity hover:opacity-90"
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

    renders_one :media, ->(aspect: :auto, **opts, &block) {
      style = "aspect-ratio: #{aspect.to_s.delete(" ")}" if aspect.to_s.match?(RATIO)
      css = style ? MEDIA : [MEDIA, Variants.fetch(ASPECTS, aspect, kind: "aspect")]
      tag.div(**merge_attrs(opts, css, style: style), &block)
    }

    def initialize(body: true, animation: nil, href: nil, link_label: nil, **html_options)
      super(**html_options)
      raise ArgumentError, "a card with href: needs link_label:, the link's accessible name" if href && link_label.blank?

      @href = href
      @link_label = link_label
      @body = body
      @animation = animation
    end

    erb_template <<~ERB
      <%= tag.div(**attrs([BASE, animation_css, (LINKED if @href)])) do %>
        <%= link_to("", @href, class: LINK, aria: {label: @link_label}) if @href %>
        <%= header if header? %>
        <%= image_top if image_top? %>
        <%= media if media? %>
        <% if @body %>
          <%= tag.div(content, class: BODY) %>
        <% else %>
          <%= content %>
        <% end %>
        <%= image_bottom if image_bottom? %>
        <%= footer if footer? %>
      <% end %>
    ERB

    private

    def animation_css
      [ANIMATION, Variants.fetch(ANIMATIONS, @animation, kind: "animation")] if @animation
    end
  end
end
