namespace :component_library_2100 do
  desc "Write app/assets/builds/component_library_2100.css so Tailwind loads the gem's theme and scans its components"
  task tailwind: :environment do
    engine_css = ComponentLibrary2100::Engine.root.join("app/assets/tailwind/component_library_2100/engine.css")
    output = Rails.root.join("app/assets/builds/component_library_2100.css")

    FileUtils.mkdir_p(output.dirname)
    File.write(output, %(@import "#{engine_css}";\n))
  end
end

# Regenerate whenever Tailwind builds, so the path survives gem upgrades and fresh checkouts.
if Rake::Task.task_defined?("tailwindcss:build") || Gem.loaded_specs.key?("tailwindcss-rails")
  task "tailwindcss:build" => "component_library_2100:tailwind"
  task "tailwindcss:watch" => "component_library_2100:tailwind"
end
