module ComponentLibrary2100
  # <%= render StatsComponent.new(columns: 3) do |stats| %>
  #   <% stats.with_stat(label: "Clients", value: "48") %>
  #   <% stats.with_stat(label: "Open invoices", value: "12", change: "3", trend: :down) %>
  #   <% stats.with_stat(label: "Revenue", value: "$12,400", change: "8%", trend: :up) %>
  # <% end %>
  #
  # A responsive grid of StatComponents (an extra: not in Bootstrap). One column on phones, two
  # from `sm`, and `columns:` (2, 3 or 4; default 3) from `lg`. Each stat takes StatComponent
  # options. `label:` names the group for screen readers (a `section` with `aria-label`).
  class StatsComponent < BaseComponent
    BASE = "grid gap-4 grid-cols-1 sm:grid-cols-2"

    COLUMNS = {
      2 => "lg:grid-cols-2",
      3 => "lg:grid-cols-3",
      4 => "lg:grid-cols-4"
    }.freeze

    renders_many :stats, "ComponentLibrary2100::StatComponent"

    def initialize(columns: 3, label: nil, **html_options)
      super(**html_options)
      @columns = columns.to_i
      @label = label
      Variants.fetch(COLUMNS, @columns, kind: "column count")
    end

    def call
      css = [BASE, COLUMNS.fetch(@columns)]
      return tag.div(safe_join(stats), **attrs(css)) unless @label

      tag.section(safe_join(stats), **attrs(css, aria: {label: @label}))
    end
  end
end
