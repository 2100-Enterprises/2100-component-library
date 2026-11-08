module ComponentLibrary2100
  # <%= render DescriptionListComponent.new do |dl| %>
  #   <% dl.with_item(term: "Status") { ui_badge "Active", variant: :success } %>
  #   <% dl.with_item(term: "Email", description: "ada@example.com") %>
  # <% end %>
  #
  # A <dl> of term/description pairs for a record's details (an extra: not in Bootstrap).
  # `layout:` is `:stacked` (default; description under the term) or `:inline` (term and
  # description in columns from the `sm` breakpoint). `dividers:` draws a line between rows
  # (default true). Each item takes the usual HTML attributes; pass a block for a rich
  # description (a badge, a link), or `description:` for plain text.
  class DescriptionListComponent < BaseComponent
    BASE = "m-0"
    TERM = "text-sm font-medium text-secondary"

    ROW = {
      stacked: "py-3",
      inline: "py-3 sm:grid sm:grid-cols-3 sm:gap-4"
    }.freeze

    DESC = {
      stacked: "mt-1 text-body",
      inline: "mt-1 text-body sm:mt-0 sm:col-span-2"
    }.freeze

    renders_many :items, ->(term:, description: nil, **opts, &block) {
      dd = block ? tag.dd(class: desc_class, &block) : tag.dd(description, class: desc_class)
      tag.div(safe_join([tag.dt(term, class: TERM), dd]), **merge_attrs(opts, row_class))
    }

    def initialize(layout: :stacked, dividers: true, **html_options)
      super(**html_options)
      @layout = layout.to_sym
      @dividers = dividers
      Variants.fetch(ROW, @layout, kind: "layout") # fail early on a bad layout
    end

    def call
      tag.dl(safe_join(items), **attrs(BASE))
    end

    private

    def row_class
      [ROW.fetch(@layout), ("border-t border-border-subtle first:border-t-0" if @dividers)]
    end

    def desc_class
      DESC.fetch(@layout)
    end
  end
end
