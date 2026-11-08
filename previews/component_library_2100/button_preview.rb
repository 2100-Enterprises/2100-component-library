module ComponentLibrary2100
  # Renders an <a> when `href:` is given, otherwise a <button>.
  # @logical_path basics
  class ButtonPreview < BasePreview
    # @param label text
    # @param variant select { choices: [primary, secondary, success, danger, warning, info, light, dark, link] }
    # @param size select { choices: [sm, md, lg] }
    # @param outline toggle
    # @param disabled toggle
    def playground(label: "Save", variant: :primary, size: :md, outline: false, disabled: false)
      render ButtonComponent.new(variant: variant, size: size, outline: outline, disabled: disabled).with_content(label)
    end

    # Every variant, solid and outline.
    def variants
      template(:variants, variants: Variants::NAMES)
    end

    # @label As a link
    def link
      render ButtonComponent.new(href: "#", outline: true).with_content("Read the docs")
    end
  end
end
