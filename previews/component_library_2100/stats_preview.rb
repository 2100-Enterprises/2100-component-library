module ComponentLibrary2100
  # @logical_path data_display
  class StatsPreview < BasePreview
    # @param columns select { choices: [2, 3, 4] }
    def playground(columns: 3)
      template(:playground, columns: columns.to_i)
    end
  end
end
