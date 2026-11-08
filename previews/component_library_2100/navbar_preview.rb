module ComponentLibrary2100
  # Below the `expand:` breakpoint the links move into an Offcanvas. Narrow the viewport to see it.
  # @logical_path navigation
  class NavbarPreview < BasePreview
    # @param theme select { choices: [light, dark, surface] }
    # @param expand select { choices: [sm, md, lg, xl, xxl] }
    def playground(theme: :light, expand: :lg)
      template(:playground, theme: theme, expand: expand)
    end
  end
end
