module ComponentLibrary2100
  # Without a variant it takes the surrounding text colour.
  # @logical_path feedback
  class SpinnerPreview < BasePreview
    # @param type select { choices: [border, grow] }
    # @param size select { choices: [sm, md] }
    # @param variant select { choices: ["", primary, secondary, success, danger, warning, info, light, dark] }
    def playground(type: :border, size: :md, variant: "")
      render SpinnerComponent.new(type: type, size: size, variant: variant.presence&.to_sym)
    end
  end
end
