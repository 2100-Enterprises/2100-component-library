module ComponentLibrary2100
  # Panels on one page, following the WAI-ARIA tabs pattern. Arrow keys move between tabs.
  # @logical_path overlays_and_interactive
  class TabsPreview < BasePreview
    # @param style select { choices: [tabs, pills] }
    def playground(style: :tabs)
      template(:playground, style: style)
    end
  end
end
