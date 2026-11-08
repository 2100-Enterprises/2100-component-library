module ComponentLibrary2100
  # @logical_path data_display
  class DescriptionListPreview < BasePreview
    # @param layout select { choices: [stacked, inline] }
    # @param dividers toggle
    def playground(layout: :stacked, dividers: true)
      template(:playground, layout: layout, dividers: dividers)
    end
  end
end
