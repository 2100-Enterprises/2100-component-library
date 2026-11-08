module ComponentLibrary2100
  # The parent of every preview. It has no examples of its own, so Lookbook doesn't list it.
  class BasePreview < ViewComponent::Preview
    private

    # Renders previews/component_library_2100/<preview>/<name>.html.erb with `locals`.
    # ViewComponent's own lookup underscores ComponentLibrary2100 to component_library2100/,
    # which isn't the folder Zeitwerk needs for the preview classes, so the path is spelled out.
    def template(name, **locals)
      render_with_template(template: "component_library_2100/#{self.class.name.demodulize.underscore}/#{name}", locals: locals)
    end
  end
end
