module ComponentLibrary2100
  # <%= render PopoverComponent.new(title: "Heads up", placement: "right") do |popover| %>
  #   <% popover.with_trigger(variant: :danger) { "Click me" } %>
  #   Rich content goes here.
  # <% end %>
  #
  # A click-to-open panel on the native popover API (outside click and Escape close it).
  # HTML attributes go on the panel; the trigger takes ButtonComponent options.
  class PopoverComponent < BaseComponent
    PANEL = "m-0 inset-auto max-w-[276px] p-0 text-sm text-body bg-surface border border-border-overlay rounded-ui-lg shadow-sm " \
            "not-data-positioned:invisible"
    TITLE = "px-4 py-2 mb-0 text-base font-medium bg-popover-header border-b border-border-overlay rounded-t-[calc(var(--radius-ui-lg)-1px)]"
    BODY = "px-4 py-3"

    renders_one :trigger, ->(**opts) { ButtonComponent.new(**merge_attrs(opts, nil, **trigger_defaults)) }

    def initialize(title: nil, placement: "right", **html_options)
      super(**html_options)
      @title = title
      @placement = placement
      @id = html_options[:id] || generated_id("popover")
    end

    def call
      tag.div(safe_join([trigger, panel]), class: "inline-block", data: {controller: "cl-popover", cl_popover_placement_value: @placement})
    end

    private

    def panel
      options = attrs(PANEL, id: @id, popover: "auto", data: {cl_popover_target: "panel", action: "toggle->cl-popover#sync"})
      if @title
        options[:role] = "dialog"
        options[:aria] = {labelledby: "#{@id}-title"}.merge(options[:aria] || {})
      end

      tag.div(safe_join([title, tag.div(content, class: BODY)]), **options)
    end

    def title
      tag.h3(@title, id: "#{@id}-title", class: TITLE) if @title
    end

    def trigger_defaults
      {variant: :secondary, popovertarget: @id, aria: {haspopup: "dialog", expanded: false}, data: {cl_popover_target: "trigger"}}
    end
  end
end
