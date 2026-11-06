require "fileutils"
require "rails"
require "view_component"
require "tailwind_merge"

require "component_library_2100/version"
require "component_library_2100/helpers"
require "component_library_2100/engine"

module ComponentLibrary2100
  # Tailwind's entry point for the gem. It lives here because tailwindcss-rails keeps this
  # directory out of Propshaft. Under app/assets/builds, `stylesheet_link_tag :app` would link
  # it, and its one line is an absolute path on the server.
  TAILWIND_ENTRY = "app/assets/tailwind/component_library_2100.css".freeze

  # Teaches TailwindMerge the `rounded-ui` tokens from engine.css, so that `rounded-md` replaces them.
  MERGER_CONFIG = {theme: {"radius" => %w[ui ui-sm ui-lg]}}.freeze

  class << self
    # Resolves conflicting Tailwind utilities so a caller's `class:` wins over a
    # component's defaults. Replace it to teach the merger about custom classes:
    #
    #   ComponentLibrary2100.merger = TailwindMerge::Merger.new(config: { ... })
    #
    # Include MERGER_CONFIG's radius names in your config, or `rounded-ui` stops merging.
    attr_writer :merger

    def merger
      @merger ||= TailwindMerge::Merger.new(config: MERGER_CONFIG)
    end

    def merge_classes(*classes)
      merger.merge(classes.flatten.compact.join(" "))
    end

    def write_tailwind_entry(root)
      output = Pathname(root).join(TAILWIND_ENTRY)
      engine_css = Engine.root.join("app/assets/tailwind/component_library_2100/engine.css")

      FileUtils.mkdir_p(output.dirname)
      File.write(output, %(@import "#{engine_css}";\n))
    end
  end
end
