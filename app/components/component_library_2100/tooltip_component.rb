module ComponentLibrary2100
  # <%= render TooltipComponent.new(text: "Copy to clipboard", placement: "bottom") do %>
  #   <%= ui_button "Copy", variant: :secondary %>
  # <% end %>
  #
  # Wrap something that can take keyboard focus (a button or link), so the tooltip also shows on focus.
  # Its first child receives `aria-describedby`. HTML attributes go on the wrapper. The tip is a
  # `popover="manual"` element in the top layer, so no ancestor can clip it.
  # placement: "top" (default), "bottom", "left", "right", with optional "-start" / "-end".
  class TooltipComponent < BaseComponent
    WRAPPER = "inline-block"
    TIP = "m-0 inset-auto max-w-[200px] px-2 py-1 text-xs text-center text-tooltip-on bg-tooltip border-0 rounded-ui overflow-visible " \
          "pointer-events-none not-data-positioned:invisible"

    def initialize(text:, placement: "top", **html_options)
      super(**html_options)
      @text = text
      @placement = placement
      @id = generated_id("tooltip")
    end

    def call
      tag.span(safe_join([content, tip]), **attrs(WRAPPER, data: {
        controller: "cl-tooltip",
        cl_tooltip_placement_value: @placement,
        action: "mouseenter->cl-tooltip#show mouseleave->cl-tooltip#hide focusin->cl-tooltip#show focusout->cl-tooltip#hide keydown.esc->cl-tooltip#hide"
      }))
    end

    private

    def tip
      tag.span(@text, id: @id, role: "tooltip", popover: "manual", class: TIP, data: {cl_tooltip_target: "tip"})
    end
  end
end
