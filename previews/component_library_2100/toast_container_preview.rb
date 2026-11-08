module ComponentLibrary2100
  # One per layout. A Turbo Stream appends toasts to it.
  # @logical_path feedback
  class ToastContainerPreview < BasePreview
    # @param placement select { choices: [top_start, top_center, top_end, bottom_start, bottom_center, bottom_end] }
    def playground(placement: :top_end)
      template(:playground, placement: placement)
    end
  end
end
