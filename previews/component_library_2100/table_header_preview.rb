module ComponentLibrary2100
  # A <th> that always has a `scope`.
  # @logical_path data_display
  class TableHeaderPreview < BasePreview
    # @param scope select { choices: [col, row, colgroup, rowgroup] }
    def playground(scope: :col)
      template(:playground, scope: scope)
    end
  end
end
