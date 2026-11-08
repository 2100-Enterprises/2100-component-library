module ComponentLibrary2100
  # <%= render SkeletonComponent.new(lines: 3) %>
  # <%= render SkeletonComponent.new(shape: :circle, class: "size-16") %>
  # <%= render SkeletonComponent.new(shape: :block, class: "h-40") %>
  #
  # A pulsing placeholder for content that is still loading (an extra: not in Bootstrap). It is
  # decorative, so it is `aria-hidden`; put `aria-busy="true"` on the region it stands in and
  # swap it for the real content when that arrives (e.g. a lazy Turbo Frame). `shape:` is `:text`
  # (default), `:block` or `:circle`; `lines:` draws that many text rows, the last one shorter.
  # Size it with `class:`. The pulse stops under `prefers-reduced-motion`.
  class SkeletonComponent < BaseComponent
    BASE = "animate-pulse motion-reduce:animate-none bg-surface-muted"

    SHAPES = {
      text: "h-4 rounded",
      block: "w-full h-24 rounded-ui",
      circle: "size-12 rounded-full"
    }.freeze

    def initialize(shape: :text, lines: 1, **html_options)
      super(**html_options)
      @shape = shape.to_sym
      @lines = lines.to_i
      Variants.fetch(SHAPES, @shape, kind: "shape") # fail early on a bad shape
    end

    def call
      return multiline if @shape == :text && @lines > 1

      tag.div(**attrs([BASE, SHAPES.fetch(@shape)], aria: {hidden: true}))
    end

    private

    # Several text rows; the last is three-quarter width so it reads as a paragraph.
    def multiline
      rows = Array.new(@lines) do |i|
        last = i == @lines - 1
        tag.div(class: ComponentLibrary2100.merge_classes([BASE, SHAPES.fetch(:text), ("w-3/4" if last)]))
      end

      tag.div(safe_join(rows), **attrs("flex flex-col gap-2", aria: {hidden: true}))
    end
  end
end
