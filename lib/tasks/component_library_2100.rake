namespace :component_library_2100 do
  desc "Write app/assets/tailwind/component_library_2100.css so Tailwind loads the gem's theme and scans its components"
  task tailwind: :environment do
    ComponentLibrary2100.write_tailwind_entry(Rails.root)
  end

  desc "Wire the library into this app (the same as bin/rails g component_library_2100:install). Safe to run again"
  task install: :environment do
    require "rails/generators"
    require "generators/component_library_2100/install/install_generator"
    ComponentLibrary2100::Generators::InstallGenerator.start([], destination_root: Rails.root.to_s)
  end
end

# Regenerate whenever Tailwind builds, so the path survives gem upgrades and fresh checkouts.
if Rake::Task.task_defined?("tailwindcss:build") || Gem.loaded_specs.key?("tailwindcss-rails")
  task "tailwindcss:build" => "component_library_2100:tailwind"
  task "tailwindcss:watch" => "component_library_2100:tailwind"
end
