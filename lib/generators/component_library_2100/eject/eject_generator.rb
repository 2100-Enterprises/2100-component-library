require "rails/generators"

module ComponentLibrary2100
  module Generators
    # rails g component_library_2100:eject button card
    #
    # Copies the component into the host app at the same path. Rails searches the app's autoload
    # paths before engines', so the copy replaces the gem's version. Prefer subclassing
    # (`class MyButton < ComponentLibrary2100::ButtonComponent`) when you only need small changes.
    class EjectGenerator < Rails::Generators::Base
      # Rails derives "component_library2100" from the class name, but the file lives under
      # generators/component_library_2100/, so the documented name would find nothing.
      namespace "component_library_2100:eject"

      desc "Copies library components into your app so you can change them freely."
      argument :names, type: :array, banner: "button card ..."

      def self.source_root
        ComponentLibrary2100::Engine.root.join("app/components/component_library_2100").to_s
      end

      def copy_components
        names.each do |name|
          file = "#{name.underscore.delete_suffix("_component")}_component.rb"
          copy_file file, "app/components/component_library_2100/#{file}"
        end
      end
    end
  end
end
