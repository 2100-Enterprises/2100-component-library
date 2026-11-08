module ComponentLibrary2100
  # @logical_path feedback
  class EmptyStatePreview < BasePreview
    # @param title text
    # @param text text
    def playground(title: "No projects yet", text: "Projects you create appear here.")
      template(:playground, title: title, text: text)
    end
  end
end
