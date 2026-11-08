module ComponentLibrary2100
  # You write the <thead> and <tbody>. The component styles them.
  # @logical_path data_display
  class TablePreview < BasePreview
    # @param striped toggle
    # @param hover toggle
    # @param bordered toggle
    # @param small toggle
    def playground(striped: true, hover: false, bordered: false, small: false)
      template(:playground, striped: striped, hover: hover, bordered: bordered, small: small)
    end
  end
end
