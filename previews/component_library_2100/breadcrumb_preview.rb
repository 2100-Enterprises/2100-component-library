module ComponentLibrary2100
  # @logical_path navigation
  class BreadcrumbPreview < BasePreview
    # The last item has no `href:`, so it's the current page.
    def default
      template(:default)
    end
  end
end
