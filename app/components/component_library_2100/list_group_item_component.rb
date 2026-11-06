module ComponentLibrary2100
  class ListGroupItemComponent < BaseComponent
    BASE = "relative block px-4 py-2 text-[#212529] bg-white border border-black/[.125] " \
           "first:rounded-t-ui last:rounded-b-ui not-first:border-t-0"
    ACTION = "w-full text-left text-[#495057] no-underline hover:z-[1] hover:bg-[#f8f9fa] hover:text-[#495057] focus:z-[1] focus:bg-[#e9ecef]"
    ACTIVE = "z-[2] bg-primary text-primary-on border-primary"
    DISABLED = "pointer-events-none text-secondary bg-white"

    def initialize(variant: nil, active: false, disabled: false, href: nil, action: false, **html_options)
      super(**html_options)
      @variant = variant
      @active = active
      @disabled = disabled
      @href = href
      @action = action
    end

    # Actionable items are links or buttons, which also changes the group's container.
    def action?
      @href.present? || @action
    end

    def call
      return tag.a(content, **attrs(css, href: @href, **state_attrs)) if @href
      return tag.button(content, **attrs(css, type: :button, disabled: @disabled, **state_attrs)) if @action

      tag.li(content, **attrs(css, **state_attrs))
    end

    private

    def css
      [
        BASE,
        (ACTION if action?),
        (Variants.fetch(Variants::SUBTLE, @variant) if @variant),
        (DISABLED if @disabled),
        (ACTIVE if @active)
      ]
    end

    def state_attrs
      {
        aria: {current: (true if @active), disabled: (true if @disabled && !@action)}.compact
      }
    end
  end
end
