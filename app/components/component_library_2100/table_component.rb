module ComponentLibrary2100
  # <%= render TableComponent.new(striped: true, hover: true, responsive: :md) do |table| %>
  #   <% table.with_caption { "Clients" } %>
  #   <thead><tr>
  #     <%= ui_table_header "Name" %>
  #     <%= ui_table_header "Email" %>
  #   </tr></thead>
  #   <tbody><tr><%= ui_table_header "Ada", scope: :row %><td>ada@example.com</td></tr></tbody>
  # <% end %>
  #
  # You write the <thead>/<tbody>; the component styles them. `responsive:` wraps the table in
  # a horizontally scrolling div: `true` always, or a breakpoint (:sm, :md, :lg, :xl, :xxl)
  # below which it scrolls. Breakpoints are Tailwind's, not Bootstrap's pixel values. With a
  # caption too, the wrapper is a focusable region named by it, so keyboard users can scroll
  # the table with the arrow keys; without one it stays a plain div, since a region needs a name.
  #
  # `with_caption` gives the table its accessible name, rendered as the <caption> before your
  # markup. It's visible by default; `with_caption(visible: false) { "Clients" }` hides it
  # visually but keeps it for screen readers. Text can be passed as an argument too:
  # `with_caption("Clients")`. For a header cell with the right `scope`, use `ui_table_header`
  # (TableHeaderComponent).
  class TableComponent < BaseComponent
    BASE = "w-full border-collapse align-top text-body " \
           "[&_:is(th,td)]:border-b [&_:is(th,td)]:border-border [&_thead_th]:align-bottom " \
           "[&>tbody:not(:first-child)]:border-t-2 [&>tbody:not(:first-child)]:border-current"
    CELL = "[&_:is(th,td)]:p-2"
    CELL_SMALL = "[&_:is(th,td)]:p-1"
    BORDERED = "[&_:is(th,td)]:border"
    STRIPED = "[&_tbody_tr:nth-of-type(odd)]:bg-surface-stripe"
    HOVER = "[&_tbody_tr:hover]:bg-surface-hover"

    CAPTION = "py-2 text-left text-secondary"
    CAPTION_HIDDEN = "sr-only"

    renders_one :caption, ->(text = nil, visible: true, **opts, &block) {
      css = visible ? CAPTION : CAPTION_HIDDEN
      @caption_id = opts[:id] ||= generated_id("table-caption")
      block ? tag.caption(**merge_attrs(opts, css), &block) : tag.caption(text, **merge_attrs(opts, css))
    }

    RESPONSIVE = {
      true => "overflow-x-auto",
      sm: "max-sm:overflow-x-auto",
      md: "max-md:overflow-x-auto",
      lg: "max-lg:overflow-x-auto",
      xl: "max-xl:overflow-x-auto",
      xxl: "max-2xl:overflow-x-auto"
    }.freeze
    # The scrolling wrapper takes focus to scroll from the keyboard, so it shows a ring.
    REGION_FOCUS = "rounded-ui focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary"

    def initialize(striped: false, hover: false, bordered: false, small: false, responsive: false, **html_options)
      super(**html_options)
      @striped = striped
      @hover = hover
      @bordered = bordered
      @small = small
      @responsive = responsive
    end

    def call
      body = content # evaluates the block first, which fills the caption slot
      table = tag.table(safe_join([caption, body]), **attrs(css))
      return table unless @responsive

      scroll = Variants.fetch(RESPONSIVE, @responsive, kind: "responsive option")
      return tag.div(table, class: scroll) unless @caption_id

      tag.div(table, class: [scroll, REGION_FOCUS], role: "region", tabindex: 0, aria: {labelledby: @caption_id})
    end

    private

    def css
      [BASE, (@small ? CELL_SMALL : CELL), (BORDERED if @bordered), (STRIPED if @striped), (HOVER if @hover)]
    end
  end
end
