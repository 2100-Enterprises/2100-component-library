module ComponentLibrary2100
  # Shared behaviour for every component.
  #
  # Anything a subclass doesn't recognise is kept as HTML attributes and rendered on the
  # root element, so callers can always pass `id:`, `data:`, `aria:` and `class:`.
  # `class:` is merged with TailwindMerge, so `class: "px-8"` replaces the default
  # horizontal padding instead of fighting it.
  class BaseComponent < ViewComponent::Base
    def initialize(**html_options)
      @html_options = html_options
      super()
    end

    private

    attr_reader :html_options

    # Attributes for the root element: component defaults, then caller overrides.
    #
    #   tag.div(**attrs("p-4 border", role: "alert"))
    def attrs(css = nil, **defaults)
      merge_attrs(html_options, css, **defaults)
    end

    # Same merge for any user-supplied hash (used by slots).
    #   - `class` is conflict-resolved, the caller's classes win
    #   - `data` / `aria` are deep merged
    #   - `data-controller` values are concatenated rather than replaced
    def merge_attrs(user, css = nil, **defaults)
      merged = defaults.deep_merge(user.except(:class))

      ours = defaults.dig(:data, :controller)
      theirs = user.dig(:data, :controller)
      merged[:data][:controller] = [ours, theirs].join(" ") if ours && theirs

      merged.merge(class: ComponentLibrary2100.merge_classes(css, user[:class]))
    end
  end
end
