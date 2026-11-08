module ComponentLibrary2100
  # @logical_path navigation
  class ScrollspyPreview < BasePreview
    # The active link follows the section in view. Scroll the page.
    def default
      template(:default)
    end
  end
end
