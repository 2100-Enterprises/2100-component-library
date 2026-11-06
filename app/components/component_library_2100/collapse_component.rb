module ComponentLibrary2100
  # <%= render CollapseComponent.new do |collapse| %>
  #   <% collapse.with_trigger(variant: :secondary) { "Details" } %>
  #   Hidden until the trigger is pressed.
  # <% end %>
  #
  # `open: true` starts expanded. HTML attributes (`id:`, `class:`) go on the panel; the trigger
  # takes ButtonComponent options. The panel animates with a grid-rows transition, so no height
  # is measured in JavaScript. To trigger it from elsewhere, put `data-action="cl-collapse#toggle"`
  # on any element inside the component.
  class CollapseComponent < BaseComponent
    PANEL = "grid grid-rows-[0fr] data-open:grid-rows-[1fr] transition-[grid-template-rows] duration-300 motion-reduce:transition-none"
    INNER = "min-h-0 overflow-hidden"

    renders_one :trigger, ->(**opts) { ButtonComponent.new(**merge_attrs(opts, nil, **trigger_defaults)) }

    def initialize(open: false, **html_options)
      super(**html_options)
      @open = open
      @id = html_options[:id] || generated_id("collapse")
    end

    def call
      tag.div(safe_join([trigger, panel]), class: "contents", data: {controller: "cl-collapse", "cl-collapse-open-value": @open})
    end

    private

    def panel
      inner = tag.div(content, class: INNER, inert: !@open, data: {cl_collapse_target: "inner"})

      tag.div(inner, **attrs(PANEL, id: @id, data: {cl_collapse_target: "panel", open: (true if @open)}))
    end

    def trigger_defaults
      {
        variant: :primary,
        aria: {controls: @id, expanded: @open},
        data: {cl_collapse_target: "trigger", action: "cl-collapse#toggle"}
      }
    end
  end
end
