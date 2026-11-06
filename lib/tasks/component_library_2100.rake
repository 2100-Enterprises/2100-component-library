namespace :component_library_2100 do
  desc "Write app/assets/tailwind/component_library_2100.css so Tailwind loads the gem's theme and scans its components"
  task tailwind: :environment do
    ComponentLibrary2100.write_tailwind_entry(Rails.root)
  end
end

# Regenerate whenever Tailwind builds, so the path survives gem upgrades and fresh checkouts.
if Rake::Task.task_defined?("tailwindcss:build") || Gem.loaded_specs.key?("tailwindcss-rails")
  task "tailwindcss:build" => "component_library_2100:tailwind"
  task "tailwindcss:watch" => "component_library_2100:tailwind"
end
