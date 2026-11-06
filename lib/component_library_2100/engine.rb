module ComponentLibrary2100
  # Not isolated on purpose: components and helpers live in the host app's namespace
  # resolution, and host copies of a component shadow the engine's (see the eject generator).
  class Engine < ::Rails::Engine
    initializer "component_library_2100.helpers" do
      ActiveSupport.on_load(:action_view) { include ComponentLibrary2100::Helpers }
    end

    initializer "component_library_2100.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
        # Sprockets only; Propshaft serves everything on its paths.
        if app.config.assets.precompile
          app.config.assets.precompile += %w[component_library_2100/index.js]
        end
      end
    end

    initializer "component_library_2100.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    rake_tasks do
      load File.expand_path("../tasks/component_library_2100.rake", __dir__)
    end
  end
end
