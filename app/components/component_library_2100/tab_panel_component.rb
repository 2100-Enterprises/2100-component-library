module ComponentLibrary2100
  # One tab and its panel. Create these through `tabs.with_tab`.
  class TabPanelComponent < BaseComponent
    attr_reader :title

    def initialize(title:, active: false, disabled: false, id: nil, **html_options)
      super(**html_options)
      @title = title
      @active = active
      @disabled = disabled
      @id = id || generated_id("tab")
    end

    def active? = @active
    def enabled? = !@disabled
    def disabled? = @disabled
    def activate! = (@active = true)
    def tab_id = "#{@id}-tab"
    def panel_id = "#{@id}-panel"

    def call
      tag.div(content, **attrs(nil, id: panel_id, role: "tabpanel", tabindex: 0, hidden: !@active,
        aria: {labelledby: tab_id}, data: {cl_tabs_target: "panel"}))
    end
  end
end
