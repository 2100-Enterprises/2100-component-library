require "rails"
require "view_component"
require "tailwind_merge"

require "component_library_2100/version"
require "component_library_2100/helpers"
require "component_library_2100/engine"

module ComponentLibrary2100
  class << self
    # Resolves conflicting Tailwind utilities so a caller's `class:` wins over a
    # component's defaults. Replace it to teach the merger about custom classes:
    #
    #   ComponentLibrary2100.merger = TailwindMerge::Merger.new(config: { ... })
    attr_writer :merger

    def merger
      @merger ||= TailwindMerge::Merger.new
    end

    def merge_classes(*classes)
      merger.merge(classes.flatten.compact.join(" "))
    end
  end
end
