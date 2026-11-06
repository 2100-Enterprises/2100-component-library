require "rails/generators"

module ComponentLibrary2100
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Wires ComponentLibrary2100 into a host app: Tailwind theme import and Stimulus controllers."

      CSS_FILE = "app/assets/tailwind/application.css".freeze
      JS_FILE = "app/javascript/controllers/index.js".freeze
      CSS_IMPORT = %(@import "../builds/component_library_2100.css";).freeze

      def import_tailwind_theme
        if exists?(CSS_FILE)
          inject_into_file CSS_FILE, "#{CSS_IMPORT}\n", after: /^@import ["']tailwindcss["'];\n/
          rake "component_library_2100:tailwind"
        else
          say_status :skip, "#{CSS_FILE} not found. Add this after @import \"tailwindcss\": #{CSS_IMPORT}", :yellow
        end
      end

      def register_stimulus_controllers
        if exists?(JS_FILE)
          append_to_file JS_FILE, <<~JS

            import { register as registerComponentLibrary2100 } from "component_library_2100"
            registerComponentLibrary2100(application)
          JS
        else
          say_status :skip, "#{JS_FILE} not found. Register the controllers manually (see README).", :yellow
        end
      end

      private

      def exists?(path)
        File.exist?(File.join(destination_root, path))
      end
    end
  end
end
