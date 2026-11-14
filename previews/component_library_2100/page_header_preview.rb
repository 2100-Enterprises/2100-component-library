module ComponentLibrary2100
  # @logical_path basics
  class PageHeaderPreview < BasePreview
    # @param title text
    # @param subtitle text
    def playground(title: "Projects", subtitle: "Everything your team is working on")
      template(:playground, title: title, subtitle: subtitle)
    end

    # A labelled back link above the title, and Previous/Next icon links. The first post has no
    # previous one, so that side is disabled.
    def back_and_pager
      template(:back_and_pager)
    end
  end
end
