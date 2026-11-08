module ComponentLibrary2100
  # A sortable column heading. You build the `href:`.
  # @logical_path data_display
  class SortHeaderPreview < BasePreview
    # @param direction select { choices: ["", asc, desc] }
    def playground(direction: "asc")
      template(:playground, direction: direction.presence&.to_sym)
    end
  end
end
