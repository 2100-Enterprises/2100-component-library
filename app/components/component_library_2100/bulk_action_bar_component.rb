module ComponentLibrary2100
  # <%= render BulkActionBarComponent.new(label: "Post actions", noun: "post", noun_plural: "posts") do |bar| %>
  #   <% bar.with_action { ui_button "Delete", variant: :danger } %>
  # <% end %>
  #
  # The bar for bulk actions on a list or table, driven by the `cl-bulk-select` controller. Put it
  # inside the controller's element. It is hidden until at least one row is selected, then
  # sticks to the bottom (`position: :top` for the top) of the viewport. It's a `role="region"`
  # named by `label:`, shows "<count> selected" (`noun:` and `noun_plural:` give "1 post selected" /
  # "3 posts selected"), a Clear button, and the `actions` slot. A separate visually hidden
  # `role="status"` element announces the count politely, because a hidden region can't.
  class BulkActionBarComponent < BaseComponent
    BASE = "sticky z-40 flex flex-wrap items-center gap-3 px-4 py-3 bg-surface text-body border border-border " \
           "rounded-ui shadow-lg"
    POSITIONS = {
      bottom: "bottom-[max(1rem,env(safe-area-inset-bottom))]",
      top: "top-4"
    }.freeze

    renders_many :actions

    def initialize(label: "Bulk actions", noun: nil, noun_plural: nil, clear: "Clear", position: :bottom, **html_options)
      super(**html_options)
      @label = label
      @noun = noun
      @noun_plural = noun_plural || (noun && "#{noun}s")
      @clear = clear
      @position = position
    end

    def call
      safe_join([bar, tag.div(class: "sr-only", role: "status", data: {cl_bulk_select_target: "status"})])
    end

    private

    def bar
      css = [BASE, Variants.fetch(POSITIONS, @position.to_sym, kind: "position")]
      tag.div(**attrs(css, role: "region", hidden: true, aria: {label: @label}, data: {cl_bulk_select_target: "bar"})) do
        safe_join([summary, tag.div(safe_join(actions), class: "flex flex-wrap items-center gap-2"), clear_button])
      end
    end

    def summary
      count = tag.span("0", class: "font-medium",
        data: {cl_bulk_select_target: "count", noun: @noun, noun_plural: @noun_plural}.compact)
      tag.span(safe_join([count, " selected"]), class: "me-auto")
    end

    def clear_button
      render(ButtonComponent.new(variant: :secondary, size: :sm, data: {action: "cl-bulk-select#clear"})) { @clear }
    end
  end
end
