module ComponentLibrary2100
  # Below the `expand:` breakpoint the links move into an Offcanvas. Narrow the viewport to see it.
  # @logical_path navigation
  class NavbarPreview < BasePreview
    # @param theme select { choices: [light, dark, surface] }
    # @param expand select { choices: [sm, md, lg, xl, xxl] }
    def playground(theme: :light, expand: :lg)
      template(:playground, theme: theme, expand: expand)
    end

    # Items and menus render in call order. In the bar a menu is a dropdown whose trigger is marked
    # current when any child is; below the breakpoint it becomes a labelled list in the panel.
    # @param theme select { choices: [light, dark, surface] }
    # @param expand select { choices: [sm, md, lg, xl, xxl] }
    def with_menus(theme: :light, expand: :lg)
      template(:with_menus, theme: theme, expand: expand)
    end
  end
end
