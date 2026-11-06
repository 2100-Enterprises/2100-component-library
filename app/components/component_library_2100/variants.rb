module ComponentLibrary2100
  # Class lookup tables for the Bootstrap colour variants.
  #
  # Every class is written out in full because Tailwind finds classes by scanning
  # source text; `"bg-#{variant}"` would never be generated. To add a variant, add
  # its tokens to `@theme` (see engine.css) and a line to each table you need, or
  # pass `class:` at the call site.
  module Variants
    NAMES = %i[primary secondary success danger warning info light dark].freeze

    # Solid fill with readable text.
    FILL = {
      primary: "bg-primary text-primary-on border-primary",
      secondary: "bg-secondary text-secondary-on border-secondary",
      success: "bg-success text-success-on border-success",
      danger: "bg-danger text-danger-on border-danger",
      warning: "bg-warning text-warning-on border-warning",
      info: "bg-info text-info-on border-info",
      light: "bg-light text-light-on border-light",
      dark: "bg-dark text-dark-on border-dark"
    }.freeze

    # Transparent until hovered.
    OUTLINE = {
      primary: "bg-transparent text-primary border-primary hover:bg-primary hover:text-primary-on",
      secondary: "bg-transparent text-secondary border-secondary hover:bg-secondary hover:text-secondary-on",
      success: "bg-transparent text-success border-success hover:bg-success hover:text-success-on",
      danger: "bg-transparent text-danger border-danger hover:bg-danger hover:text-danger-on",
      warning: "bg-transparent text-warning border-warning hover:bg-warning hover:text-warning-on",
      info: "bg-transparent text-info border-info hover:bg-info hover:text-info-on",
      light: "bg-transparent text-light border-light hover:bg-light hover:text-light-on",
      dark: "bg-transparent text-dark border-dark hover:bg-dark hover:text-dark-on"
    }.freeze

    # Tinted surface (alerts, list group items).
    SUBTLE = {
      primary: "bg-primary-subtle text-primary-emphasis border-primary-border",
      secondary: "bg-secondary-subtle text-secondary-emphasis border-secondary-border",
      success: "bg-success-subtle text-success-emphasis border-success-border",
      danger: "bg-danger-subtle text-danger-emphasis border-danger-border",
      warning: "bg-warning-subtle text-warning-emphasis border-warning-border",
      info: "bg-info-subtle text-info-emphasis border-info-border",
      light: "bg-light-subtle text-light-emphasis border-light-border",
      dark: "bg-dark-subtle text-dark-emphasis border-dark-border"
    }.freeze

    # Background colour only (progress bars).
    BG = {
      primary: "bg-primary",
      secondary: "bg-secondary",
      success: "bg-success",
      danger: "bg-danger",
      warning: "bg-warning",
      info: "bg-info",
      light: "bg-light",
      dark: "bg-dark"
    }.freeze

    # Text colour only (spinners).
    TEXT = {
      primary: "text-primary",
      secondary: "text-secondary",
      success: "text-success",
      danger: "text-danger",
      warning: "text-warning",
      info: "text-info",
      light: "text-light",
      dark: "text-dark"
    }.freeze

    # Focus ring colour.
    RING = {
      primary: "focus-visible:ring-primary/50",
      secondary: "focus-visible:ring-secondary/50",
      success: "focus-visible:ring-success/50",
      danger: "focus-visible:ring-danger/50",
      warning: "focus-visible:ring-warning/50",
      info: "focus-visible:ring-info/50",
      light: "focus-visible:ring-light/50",
      dark: "focus-visible:ring-dark/50"
    }.freeze

    module_function

    # Looks up `key` in a table, failing loudly with the valid options.
    def fetch(table, key, kind: "variant")
      key = key.to_sym if key.respond_to?(:to_sym)

      table.fetch(key) do
        raise ArgumentError, "Unknown #{kind} #{key.inspect}. Expected one of: #{table.keys.map(&:inspect).join(", ")}"
      end
    end
  end
end
