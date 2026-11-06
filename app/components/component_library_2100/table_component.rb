module ComponentLibrary2100
  # <%= render TableComponent.new(striped: true, hover: true, responsive: :md) do %>
  #   <thead>...</thead> <tbody>...</tbody>
  # <% end %>
  #
  # You write the <thead>/<tbody>; the component styles them. `responsive:` wraps the table in
  # a horizontally scrolling div: `true` always, or a breakpoint (:sm, :md, :lg, :xl, :xxl)
  # below which it scrolls. Breakpoints are Tailwind's, not Bootstrap's pixel values.
  class TableComponent < BaseComponent
    BASE = "w-full border-collapse align-top text-[#212529] " \
           "[&_:is(th,td)]:border-b [&_:is(th,td)]:border-[#dee2e6] [&_thead_th]:align-bottom " \
           "[&>tbody:not(:first-child)]:border-t-2 [&>tbody:not(:first-child)]:border-current"
    CELL = "[&_:is(th,td)]:p-2"
    CELL_SMALL = "[&_:is(th,td)]:p-1"
    BORDERED = "[&_:is(th,td)]:border"
    STRIPED = "[&_tbody_tr:nth-of-type(odd)]:bg-black/5"
    HOVER = "[&_tbody_tr:hover]:bg-black/[.075]"

    RESPONSIVE = {
      true => "overflow-x-auto",
      sm: "max-sm:overflow-x-auto",
      md: "max-md:overflow-x-auto",
      lg: "max-lg:overflow-x-auto",
      xl: "max-xl:overflow-x-auto",
      xxl: "max-2xl:overflow-x-auto"
    }.freeze

    def initialize(striped: false, hover: false, bordered: false, small: false, responsive: false, **html_options)
      super(**html_options)
      @striped = striped
      @hover = hover
      @bordered = bordered
      @small = small
      @responsive = responsive
    end

    def call
      table = tag.table(content, **attrs(css))
      return table unless @responsive

      tag.div(table, class: Variants.fetch(RESPONSIVE, @responsive, kind: "responsive option"))
    end

    private

    def css
      [BASE, (@small ? CELL_SMALL : CELL), (BORDERED if @bordered), (STRIPED if @striped), (HOVER if @hover)]
    end
  end
end
