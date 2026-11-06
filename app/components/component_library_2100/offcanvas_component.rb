module ComponentLibrary2100
  # <%= render OffcanvasComponent.new(title: "Filters", placement: :end) do |panel| %>
  #   <% panel.with_trigger(variant: :secondary) { "Filters" } %>
  #   ...
  # <% end %>
  #
  # A modal <dialog> docked to an edge. Same slots, actions and behaviour as ModalComponent
  # (`trigger`, `footer`, `cl-dialog#open`, `static_backdrop:`). placement: :start (default), :end, :top, :bottom.
  # It slides in with a CSS transition where the browser supports `@starting-style`, and just appears elsewhere.
  class OffcanvasComponent < ModalComponent
    DOCK = "m-0 max-w-none max-h-none w-auto p-0 text-[#212529] bg-white border-0 border-black/20 outline-none backdrop:bg-black/50 " \
           "open:flex open:flex-col transition-transform duration-300 transition-discrete motion-reduce:transition-none"

    PLACEMENTS = {
      start: "inset-y-0 left-0 right-auto h-full w-[400px] max-w-full border-r " \
             "-translate-x-full open:translate-x-0 starting:open:-translate-x-full",
      end: "inset-y-0 right-0 left-auto h-full w-[400px] max-w-full border-l " \
           "translate-x-full open:translate-x-0 starting:open:translate-x-full",
      top: "inset-x-0 top-0 bottom-auto h-[30vh] w-full border-b " \
           "-translate-y-full open:translate-y-0 starting:open:-translate-y-full",
      bottom: "inset-x-0 bottom-0 top-auto h-[30vh] w-full border-t " \
              "translate-y-full open:translate-y-0 starting:open:translate-y-full"
    }.freeze

    def initialize(title: nil, placement: :start, static_backdrop: false, **html_options)
      super(title: title, static_backdrop: static_backdrop, **html_options)
      @placement = placement
    end

    # Declared here so ViewComponent compiles this subclass; the markup is the parent's.
    def call = super # rubocop:disable Lint/UselessMethodDefinition

    private

    def dialog_css = [DOCK, Variants.fetch(PLACEMENTS, @placement, kind: "placement")]
  end
end
