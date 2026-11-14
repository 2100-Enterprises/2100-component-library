module ComponentLibrary2100
  # Checkboxes or radios drawn as pills or a segmented control, for forms.
  # @logical_path forms
  class ToggleGroupPreview < BasePreview
    # @param type select { choices: [checkbox, radio] }
    # @param style select { choices: [pills, segmented] }
    # @param size select { choices: [sm, md] }
    # @param legend_visible toggle
    def playground(type: :checkbox, style: :pills, size: :md, legend_visible: true)
      render ToggleGroupComponent.new(name: "platforms", label: "Platforms", type: type, style: style, size: size,
        legend_visible: legend_visible) do |group|
        group.with_option("Instagram", value: "instagram", checked: true)
        group.with_option("TikTok", value: "tiktok", variant: :success)
        group.with_option("LinkedIn", value: "linkedin")
        group.with_option("Threads", value: "threads", disabled: true)
      end
    end

    # The block is the icon and `label:` is its hidden accessible name.
    def icon_only
      grid = '<svg viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M1 1h6v6H1zm8 0h6v6H9zM1 9h6v6H1zm8 0h6v6H9z"/></svg>'.html_safe
      list = '<svg viewBox="0 0 16 16" width="16" height="16" fill="currentColor"><path d="M1 2h14v2H1zm0 5h14v2H1zm0 5h14v2H1z"/></svg>'.html_safe
      render ToggleGroupComponent.new(name: "view", label: "View", type: :radio, style: :segmented, legend_visible: false) do |group|
        group.with_option(value: "grid", checked: true, icon_only: true, label: "Grid view") { grid }
        group.with_option(value: "list", icon_only: true, label: "List view") { list }
      end
    end
  end
end
