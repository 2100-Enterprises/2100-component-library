module ComponentLibrary2100
  # <%= render PageHeaderComponent.new(title: "Projects", subtitle: "Everything your team is working on") do |header| %>
  #   <% header.with_breadcrumb do %>
  #     <%= ui_breadcrumb { |c| c.with_item("Home", href: "/"); c.with_item("Projects") } %>
  #   <% end %>
  #   <% header.with_badge(variant: :success) { "Live" } %>
  #   <% header.with_actions do %>
  #     <%= ui_button "New project", href: new_project_path %>
  #   <% end %>
  # <% end %>
  #
  # The top of a page: breadcrumb, title with badges, subtitle and actions (an extra: not in
  # Bootstrap). Actions sit to the right from the `sm` breakpoint and wrap below the title on
  # narrow screens. Badges take BadgeComponent options. `level:` picks the heading tag (default 1).
  # Block content renders under the subtitle.
  #
  # `back: {href:, label:}` puts a labelled back link (chevron and visible text, such as
  # "Planned posts") above the title. Name the place it goes to, not "Back".
  #
  # `with_pager(prev: {href:, label:}, next: {href:, label:})` adds Previous and Next icon links
  # for stepping through records. The label is the link's accessible name ("Previous post").
  # Leave a side out (nil) to omit it, or give it no `href:` to show it disabled, so the other
  # side stays in place. The links sit in a `<nav aria-label="Pagination">`; `label:` renames it
  # when a page has more than one.
  #
  # <%= render PageHeaderComponent.new(title: "Launch post", back: {href: posts_path, label: "Planned posts"}) do |header| %>
  #   <% header.with_pager(prev: {href: post_path(1), label: "Previous post"}, next: {label: "Next post"}) %>
  # <% end %>
  class PageHeaderComponent < BaseComponent
    BASE = "flex flex-col gap-2"
    ROW = "flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between"
    HEADING = "flex flex-wrap items-center gap-2"
    TITLE = "m-0 text-3xl font-medium leading-tight"
    SUBTITLE = "m-0 mt-1 text-secondary"
    ACTIONS = "flex flex-wrap items-center gap-2 sm:shrink-0"
    SIDE = "flex flex-wrap items-center gap-3 sm:shrink-0"
    BACK = "#{Variants::TOUCH_TARGET} inline-flex items-center gap-1 mb-1 text-primary no-underline hover:underline " \
           "rounded-ui focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    PAGER = "flex items-center gap-1"
    PAGER_LINK = "inline-flex size-9 pointer-coarse:size-11 items-center justify-center rounded-ui border border-border-input " \
                 "text-primary no-underline hover:bg-surface-subtle " \
                 "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2"
    PAGER_DISABLED = "inline-flex size-9 pointer-coarse:size-11 items-center justify-center rounded-ui border border-border-input " \
                     "text-secondary opacity-50 cursor-not-allowed"
    ICON = "size-4 shrink-0"
    CHEVRONS = {prev: "M10 3L5 8l5 5", next: "M6 3l5 5-5 5"}.freeze

    renders_one :breadcrumb, ->(**opts, &block) { tag.div(**merge_attrs(opts, nil), &block) }
    renders_many :badges, "ComponentLibrary2100::BadgeComponent"
    renders_one :actions, ->(**opts, &block) { tag.div(**merge_attrs(opts, ACTIONS), &block) }

    renders_one :pager, ->(label: "Pagination", **sides) {
      links = %i[prev next].filter_map { |side| pager_link(side, sides[side]) if sides[side] }
      tag.nav(safe_join(links), class: PAGER, aria: {label: label})
    }

    def initialize(title:, subtitle: nil, level: 1, back: nil, **html_options)
      super(**html_options)
      @back = back
      @title = title
      @subtitle = subtitle
      @level = level.to_i.clamp(1, 6)
    end

    def call
      row = tag.div(safe_join([main, side].compact), class: ROW)

      tag.div(safe_join([breadcrumb, row].compact), **attrs(BASE))
    end

    private

    def side
      return actions unless pager?

      tag.div(safe_join([pager, actions].compact), class: SIDE)
    end

    def back_link
      return unless @back

      link_to(@back[:href], class: BACK) do
        safe_join([icon(:prev), tag.span(@back[:label])])
      end
    end

    def pager_link(side, config)
      config = config.to_h.symbolize_keys
      label = config[:label] || side.to_s.capitalize
      icon = icon(side)

      if config[:href].present?
        link_to(config[:href], class: PAGER_LINK, aria: {label: label}, rel: side.to_s) { icon }
      else
        tag.span(icon, class: PAGER_DISABLED, role: "link", aria: {label: label, disabled: true})
      end
    end

    def icon(direction)
      tag.svg(
        tag.path(d: CHEVRONS.fetch(direction)),
        class: ICON, viewBox: "0 0 16 16", fill: "none", stroke: "currentColor",
        "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", aria: {hidden: true}
      )
    end

    def main
      heading = tag.div(safe_join([content_tag(:"h#{@level}", @title, class: TITLE), *badges]), class: HEADING)
      subtitle = tag.p(@subtitle, class: SUBTITLE) if @subtitle

      tag.div(safe_join([back_link, heading, subtitle, content].compact), class: "min-w-0")
    end
  end
end
