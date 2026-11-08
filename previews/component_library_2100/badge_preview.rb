module ComponentLibrary2100
  # @logical_path basics
  class BadgePreview < BasePreview
    # @param text text
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark] }
    # @param pill toggle
    def playground(text: "New", variant: :primary, pill: false)
      render BadgeComponent.new(variant: variant, pill: pill).with_content(text)
    end

    # Every variant, square and pill.
    def variants
      template(:variants, variants: Variants::NAMES)
    end
  end
end
