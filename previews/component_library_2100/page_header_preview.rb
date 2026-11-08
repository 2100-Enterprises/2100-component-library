module ComponentLibrary2100
  # @logical_path basics
  class PageHeaderPreview < BasePreview
    # @param title text
    # @param subtitle text
    def playground(title: "Projects", subtitle: "Everything your team is working on")
      template(:playground, title: title, subtitle: subtitle)
    end
  end
end
