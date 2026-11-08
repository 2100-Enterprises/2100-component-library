module ComponentLibrary2100
  # A round badge of initials. Screen readers hear the name, not the letters.
  # @logical_path basics
  class AvatarPreview < BasePreview
    # @param name text
    # @param initials text "Overrides the initials taken from the name"
    # @param size select { choices: [sm, md] }
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark] }
    def playground(name: "Ada Lovelace", initials: "", size: :md, variant: :secondary)
      render AvatarComponent.new(name: name, initials: initials.presence, size: size, variant: variant)
    end

    # Every variant, at both sizes.
    def variants
      template(:variants, variants: Variants::NAMES)
    end
  end
end
