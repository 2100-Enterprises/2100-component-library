module ComponentLibrary2100
  # @logical_path navigation
  class PaginationPreview < BasePreview
    # @param size select { choices: [sm, md, lg] }
    def playground(size: :md)
      template(:playground, size: size)
    end
  end
end
