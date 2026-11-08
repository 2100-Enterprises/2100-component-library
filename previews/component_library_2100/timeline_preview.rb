module ComponentLibrary2100
  # @logical_path data_display
  class TimelinePreview < BasePreview
    # @param alternate toggle "Alternate sides from md up"
    def playground(alternate: false)
      template(:playground, alternate: alternate)
    end
  end
end
