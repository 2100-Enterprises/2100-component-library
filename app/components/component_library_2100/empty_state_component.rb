module ComponentLibrary2100
  # <%= render EmptyStateComponent.new(title: "No projects yet", text: "Projects you create appear here.") do |empty| %>
  #   <% empty.with_icon { inline_svg_tag "folder.svg" } %>
  #   <% empty.with_action { ui_button "New project", href: new_project_path } %>
  # <% end %>
  #
  # A centred placeholder for a list or page with nothing in it yet (an extra: not in Bootstrap).
  # The icon is decorative (`aria-hidden`); an <svg> inside it is sized to 3rem. `level:` picks
  # the heading tag (default 2). Any block content renders between the text and the action.
  class EmptyStateComponent < BaseComponent
    BASE = "flex flex-col items-center gap-2 px-4 py-12 text-center"
    ICON = "mb-2 text-secondary [&_svg]:size-12"
    TITLE = "m-0 text-xl font-medium leading-tight"
    TEXT = "m-0 max-w-prose text-secondary"
    ACTION = "mt-3 flex flex-wrap justify-center gap-2"

    renders_one :icon, ->(**opts, &block) { tag.div(**merge_attrs(opts, ICON, aria: {hidden: true}), &block) }
    renders_one :action, ->(**opts, &block) { tag.div(**merge_attrs(opts, ACTION), &block) }

    def initialize(title:, text: nil, level: 2, **html_options)
      super(**html_options)
      @title = title
      @text = text
      @level = level.to_i.clamp(1, 6)
    end

    def call
      heading = content_tag(:"h#{@level}", @title, class: TITLE)
      text = tag.p(@text, class: TEXT) if @text

      tag.div(safe_join([icon, heading, text, content, action].compact), **attrs(BASE))
    end
  end
end
