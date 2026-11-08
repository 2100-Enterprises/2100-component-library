module ComponentLibrary2100
  # <%= render OffcanvasComponent.new(title: "Filters", placement: :end) do |panel| %>
  #   <% panel.with_trigger(variant: :secondary) { "Filters" } %>
  #   ...
  # <% end %>
  #
  # A modal <dialog> docked to an edge. Same slots, actions and behaviour as ModalComponent
  # (`trigger`, `footer`, `cl-dialog#open`, `static_backdrop:`, `close:`). placement: :start (default), :end, :top, :bottom.
  # The panel needs an accessible name: `title:` (shown as a heading) or `aria: {label: "..."}`
  # (or `aria-labelledby`); without one it raises ArgumentError. It slides in and out, and its backdrop fades, where the browser supports `@starting-style`; elsewhere it just appears.
  class OffcanvasComponent < ModalComponent
    DOCK = "m-0 max-w-none max-h-none w-auto p-0 text-body bg-surface border-0 border-border-translucent outline-none #{BACKDROP} " \
           "open:flex flex-col transition-[translate,display,overlay] duration-300 transition-discrete motion-reduce:transition-none"

    PLACEMENTS = {
      start: "inset-y-0 left-0 right-auto h-full w-[400px] max-w-full border-r " \
             "-translate-x-full open:translate-x-0 starting:open:-translate-x-full",
      end: "inset-y-0 right-0 left-auto h-full w-[400px] max-w-full border-l " \
           "translate-x-full open:translate-x-0 starting:open:translate-x-full",
      top: "inset-x-0 top-0 bottom-auto h-[30dvh] w-full border-b " \
           "-translate-y-full open:translate-y-0 starting:open:-translate-y-full",
      bottom: "inset-x-0 bottom-0 top-auto h-[30dvh] w-full border-t " \
              "translate-y-full open:translate-y-0 starting:open:translate-y-full"
    }.freeze

    def initialize(title: nil, placement: :start, static_backdrop: false, close: {}, **html_options)
      super(title: title, static_backdrop: static_backdrop, close: close, **html_options)
      raise ArgumentError, "OffcanvasComponent needs a title: or aria: {label: ...} to name the dialog" unless title || named?
      @placement = placement
    end

    # Declared here so ViewComponent compiles this subclass; the markup is the parent's.
    def call = super # rubocop:disable Lint/UselessMethodDefinition

    private

    def named?
      aria = html_options[:aria] || {}
      [aria[:label], aria[:labelledby], html_options[:"aria-label"], html_options[:"aria-labelledby"]].any?(&:present?)
    end

    def dialog_css = [DOCK, Variants.fetch(PLACEMENTS, @placement, kind: "placement")]
  end
end
