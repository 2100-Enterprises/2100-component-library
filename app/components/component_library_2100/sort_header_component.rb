module ComponentLibrary2100
  # <%= ui_table do %>
  #   <thead><tr>
  #     <%= ui_sort_header "Name", href: clients_path(sort: "name", dir: next_dir("name")), direction: dir_for("name") %>
  #     <th scope="col">Email</th>
  #   </tr></thead>
  #   ...
  # <% end %>
  #
  # A sortable column heading (an extra: not in Bootstrap): a <th scope="col"> holding a link that
  # re-sorts the table. You build `href:` (query params, a Turbo Frame), so it works with any
  # sorting backend. `direction:` is the column's current sort, `:asc`, `:desc` or nil when the
  # table isn't sorted by it; the sorted column gets `aria-sort` and an arrow, the others a faint
  # up/down icon that darkens on hover. `align: :end` right-aligns numeric columns. HTML
  # attributes go on the <th>; `link:` takes options for the <a> (e.g. `data: {turbo_frame: "list"}`).
  class SortHeaderComponent < BaseComponent
    # align-middle: a reversed inline-flex takes its baseline from the icon, which would lift
    # end-aligned headings above their neighbours.
    LINK = "group inline-flex items-center gap-1 align-middle rounded-ui-sm text-body no-underline hover:text-primary " \
           "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/50 #{Variants::TOUCH_TARGET}".freeze
    ICON = "size-4 shrink-0"
    IDLE = "opacity-40 group-hover:opacity-100 group-focus-visible:opacity-100"

    DIRECTIONS = {
      asc: {aria: "ascending", icon: "m7.247 4.86-4.796 5.481c-.566.647-.106 1.659.753 1.659h9.592a1 1 0 0 0 .753-1.659l-4.796-5.48a1 1 0 0 0-1.506 0z"},
      desc: {aria: "descending", icon: "M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"}
    }.freeze
    UNSORTED_ICON = "M3.646 9.146a.5.5 0 0 1 .708 0L8 12.793l3.646-3.647a.5.5 0 0 1 .708.708l-4 4a.5.5 0 0 1-.708 0l-4-4a.5.5 0 0 1 0-.708zm0-2.292a.5.5 0 0 0 .708 0L8 3.207l3.646 3.647a.5.5 0 0 0 .708-.708l-4-4a.5.5 0 0 0-.708 0l-4 4a.5.5 0 0 0 0 .708z"

    ALIGN = {start: "text-left", end: "text-right"}.freeze
    # The label stays first in the DOM (reading order, and the link's baseline comes from text);
    # end-aligned columns show the icon on the left by reversing the row.
    ORDER = {start: nil, end: "flex-row-reverse"}.freeze

    def initialize(href:, direction: nil, align: :start, link: {}, **html_options)
      super(**html_options)
      @href = href
      @direction = direction&.to_sym
      @align = align.to_sym
      @link = link
      Variants.fetch(DIRECTIONS, @direction, kind: "direction") if @direction
      Variants.fetch(ALIGN, @align, kind: "alignment")
    end

    def call
      sort = DIRECTIONS[@direction]
      aria = sort ? {sort: sort[:aria]} : {}
      parts = [tag.span(content), icon(sort)]

      anchor = tag.a(safe_join(parts), **merge_attrs(@link, [LINK, ORDER.fetch(@align)], href: @href))
      tag.th(anchor, **attrs(ALIGN.fetch(@align), scope: "col", aria: aria))
    end

    private

    def icon(sort)
      path = sort ? sort[:icon] : UNSORTED_ICON
      css = sort ? ICON : [ICON, IDLE].join(" ")
      tag.svg(tag.path(d: path), viewBox: "0 0 16 16", fill: "currentColor", class: css, aria: {hidden: true})
    end
  end
end
