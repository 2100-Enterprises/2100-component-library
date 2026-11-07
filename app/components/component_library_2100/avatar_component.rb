module ComponentLibrary2100
  # <%= render AvatarComponent.new(name: "Ada Lovelace") %>                  <%# "AL" %>
  # <%= render AvatarComponent.new(name: "Ada Lovelace", size: :sm, variant: :primary) %>
  # <%= render AvatarComponent.new(name: "Ada Lovelace", initials: "A") %>
  #
  # A round badge of initials (an extra: Bootstrap has no avatar). Initials come from the first
  # and last words of `name:` unless you pass `initials:`. Screen readers hear the name, not the
  # letters; `label:` overrides it. Without a name or label the avatar is hidden from assistive
  # technology, so use that only beside text that already names the person.
  # size: :sm or :md (default). variant: any Variants name (default :secondary).
  class AvatarComponent < BaseComponent
    BASE = "inline-flex items-center justify-center shrink-0 rounded-full font-medium leading-none uppercase select-none overflow-hidden"
    SIZES = {sm: "size-8 text-xs", md: "size-10 text-sm"}.freeze

    def initialize(name: nil, initials: nil, label: nil, size: :md, variant: :secondary, **html_options)
      super(**html_options)
      @name = name
      @initials = initials
      @label = label || name
      @size = size
      @variant = variant
    end

    def initials
      @initials || self.class.initials_for(@name)
    end

    def self.initials_for(name)
      words = name.to_s.split
      return "" if words.empty?

      [words.first, (words.last if words.size > 1)].compact.map { |word| word.grapheme_clusters.first }.join.upcase
    end

    def call
      tag.span(tag.span(initials, aria: {hidden: true}), **attrs(css, **a11y))
    end

    private

    def css
      [BASE, Variants.fetch(SIZES, @size, kind: "size"), Variants.fetch(Variants::FILL, @variant)]
    end

    def a11y
      @label.present? ? {role: "img", aria: {label: @label}} : {aria: {hidden: true}}
    end
  end
end
