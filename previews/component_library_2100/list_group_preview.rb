module ComponentLibrary2100
  # @logical_path data_display
  class ListGroupPreview < BasePreview
    # @param flush toggle "No outer border"
    # @param numbered toggle
    def playground(flush: false, numbered: false)
      template(:playground, flush: flush, numbered: numbered)
    end

    # With `href:` the group is a <div> of links.
    def links
      template(:links)
    end
  end
end
