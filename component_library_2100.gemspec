require_relative "lib/component_library_2100/version"

Gem::Specification.new do |spec|
  spec.name = "component_library_2100"
  spec.version = ComponentLibrary2100::VERSION
  spec.authors = ["Michael Cain"]
  spec.summary = "Bootstrap 5-style components for Rails, built with ViewComponent, Stimulus and Tailwind CSS v4."
  spec.license = "MIT"
  spec.homepage = "https://github.com/the-codetrane/2100-component-library"
  spec.metadata = {
    "changelog_uri" => "#{spec.homepage}/blob/development/CHANGELOG.md",
    "source_code_uri" => spec.homepage
  }
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "LICENSE", "README.md"]

  spec.add_dependency "rails", ">= 7.1", "< 9"
  spec.add_dependency "view_component", ">= 4.0", "< 5"
  spec.add_dependency "tailwind_merge", ">= 1.5.1", "< 2"
end
