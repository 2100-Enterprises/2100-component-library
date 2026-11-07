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
  class PageHeaderComponent < BaseComponent
    BASE = "flex flex-col gap-2"
    ROW = "flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between"
    HEADING = "flex flex-wrap items-center gap-2"
    TITLE = "m-0 text-3xl font-medium leading-tight"
    SUBTITLE = "m-0 mt-1 text-secondary"
    ACTIONS = "flex flex-wrap items-center gap-2 sm:shrink-0"

    renders_one :breadcrumb, ->(**opts, &block) { tag.div(**merge_attrs(opts, nil), &block) }
    renders_many :badges, "ComponentLibrary2100::BadgeComponent"
    renders_one :actions, ->(**opts, &block) { tag.div(**merge_attrs(opts, ACTIONS), &block) }

    def initialize(title:, subtitle: nil, level: 1, **html_options)
      super(**html_options)
      @title = title
      @subtitle = subtitle
      @level = level.to_i.clamp(1, 6)
    end

    def call
      tag.div(safe_join([breadcrumb, tag.div(safe_join([main, actions].compact), class: ROW)].compact), **attrs(BASE))
    end

    private

    def main
      heading = tag.div(safe_join([content_tag(:"h#{@level}", @title, class: TITLE), *badges]), class: HEADING)
      subtitle = tag.p(@subtitle, class: SUBTITLE) if @subtitle

      tag.div(safe_join([heading, subtitle, content].compact), class: "min-w-0")
    end
  end
end
