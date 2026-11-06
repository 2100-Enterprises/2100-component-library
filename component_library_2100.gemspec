require_relative "lib/component_library_2100/version"

Gem::Specification.new do |spec|
  spec.name = "component_library_2100"
  spec.version = ComponentLibrary2100::VERSION
  spec.authors = ["Michael Cain"]
  spec.summary = "Bootstrap 5-style components for Rails, built with ViewComponent, Stimulus and Tailwind CSS v4."
  spec.homepage = "https://github.com/the-codetrane/2100-component-library"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "README.md"]

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "view_component", ">= 4.0", "< 5"
  spec.add_dependency "tailwind_merge", ">= 0.13"
end
