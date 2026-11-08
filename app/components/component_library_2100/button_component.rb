module ComponentLibrary2100
  # <%= render ButtonComponent.new(variant: :success, size: :lg) { "Save" } %>
  # <%= render ButtonComponent.new(href: "/pricing", outline: true) { "Pricing" } %>
  #
  # Renders an <a> when `href:` is given, otherwise a <button>.
  class ButtonComponent < BaseComponent
    # One focus style for every variant: a solid ring set off from the button, so it shows on any fill.
    FOCUS = "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    # inline-flex centres the label in a box taller than its text (a min-h- class), and lines up an icon beside it.
    BASE = "#{Variants::TOUCH_TARGET} inline-flex items-center justify-center gap-1.5 text-center font-medium leading-normal border " \
           "cursor-pointer select-none no-underline transition duration-150 " \
           "#{FOCUS} " \
           "disabled:opacity-65 disabled:pointer-events-none aria-disabled:opacity-65 aria-disabled:pointer-events-none"

    SIZES = {
      sm: "px-2 py-1 text-sm rounded-ui-sm",
      md: "px-3 py-1.5 text-base rounded-ui",
      lg: "px-4 py-2 text-xl rounded-ui-lg"
    }.freeze

    LINK = "bg-transparent text-primary border-transparent underline"

    def initialize(variant: :primary, size: :md, outline: false, href: nil, type: :button, disabled: false, **html_options)
      super(**html_options)
      @variant = variant.to_sym
      @size = size.to_sym
      @outline = outline
      @href = href
      @type = type
      @disabled = disabled
    end

    def call
      if @href
        tag.a(content, **attrs(css, href: @href, **disabled_anchor_attrs))
      else
        tag.button(content, **attrs(css, type: @type, disabled: @disabled))
      end
    end

    private

    def css
      [BASE, Variants.fetch(SIZES, @size, kind: "size"), color_classes]
    end

    def color_classes
      return LINK if @variant == :link
      return Variants.fetch(Variants::OUTLINE, @variant) if @outline

      [Variants.fetch(Variants::FILL, @variant), "hover:brightness-90"]
    end

    def disabled_anchor_attrs
      @disabled ? {aria: {disabled: true}, tabindex: -1} : {}
    end
  end
end
