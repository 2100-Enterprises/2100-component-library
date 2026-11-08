module ComponentLibrary2100
  # Links between pages. For panels on one page, use Tabs.
  # @logical_path navigation
  class NavPreview < BasePreview
    # @param style select { choices: [tabs, pills] }
    # @param fill toggle
    # @param justified toggle
    def playground(style: :tabs, fill: false, justified: false)
      template(:playground, style: style, fill: fill, justified: justified)
    end
  end
end
