module ComponentLibrary2100
  # <%= render BadgeComponent.new(variant: :danger, pill: true) { "4" } %>
  class BadgeComponent < BaseComponent
    BASE = "inline-block px-[.65em] py-[.35em] text-[.75em] font-bold leading-none text-center whitespace-nowrap align-baseline"

    def initialize(variant: :primary, pill: false, **html_options)
      super(**html_options)
      @variant = variant
      @pill = pill
    end

    def call
      tag.span(content, **attrs([BASE, @pill ? "rounded-full" : "rounded-ui", Variants.fetch(Variants::FILL, @variant)]))
    end
  end
end
