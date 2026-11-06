module ComponentLibrary2100
  # <%= render SpinnerComponent.new(variant: :primary, size: :sm) %>
  # <%= render SpinnerComponent.new(type: :grow, label: "Saving...") %>
  #
  # Without a variant the spinner inherits the surrounding text colour.
  class SpinnerComponent < BaseComponent
    BORDER = "inline-block align-[-.125em] rounded-full border-current border-r-transparent animate-spin"
    GROW = "inline-block align-[-.125em] rounded-full bg-current opacity-0 animate-spinner-grow"
    SIZES = {
      border: {sm: "size-4 border-[.2em]", md: "size-8 border-[.25em]"},
      grow: {sm: "size-4", md: "size-8"}
    }.freeze

    def initialize(type: :border, size: :md, variant: nil, label: "Loading...", **html_options)
      super(**html_options)
      @type = type.to_sym
      @size = size
      @variant = variant
      @label = label
    end

    def call
      tag.div(tag.span(@label, class: "sr-only"), **attrs(css, role: "status"))
    end

    private

    def css
      sizes = Variants.fetch(SIZES, @type, kind: "type")
      [@type == :grow ? GROW : BORDER, Variants.fetch(sizes, @size, kind: "size"), (Variants.fetch(Variants::TEXT, @variant) if @variant)]
    end
  end
end
