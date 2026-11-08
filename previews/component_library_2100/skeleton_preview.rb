module ComponentLibrary2100
  # Pulsing placeholders for content still loading. Size them with `class:`.
  # @logical_path feedback
  class SkeletonPreview < BasePreview
    def default
      template(:default)
    end
  end
end
