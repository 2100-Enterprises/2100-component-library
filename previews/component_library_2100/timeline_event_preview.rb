module ComponentLibrary2100
  # @logical_path data_display
  class TimelineEventPreview < BasePreview
    # One event on its own, as a Turbo Stream prepends it. The <ol> stands in for the Timeline.
    # @param title text
    # @param variant select { choices: ["", primary, secondary, success, danger, warning, info, light, dark] }
    # @param icon text
    def playground(title: "File uploaded", variant: "success", icon: "")
      template(:playground, title: title, variant: variant.presence&.to_sym, icon: icon.presence)
    end
  end
end
