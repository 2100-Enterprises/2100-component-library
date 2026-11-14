require "test_helper"
require "tmpdir"
require "generators/component_library_2100/install/install_generator"

class InstallTest < ActiveSupport::TestCase
  def in_host_app
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "app/assets/tailwind"))
      File.write(File.join(root, "app/assets/tailwind/application.css"), %(@import "tailwindcss";\n))
      File.write(File.join(root, ".gitignore"), "/log/*\n")
      yield root
    end
  end

  def install(root)
    ComponentLibrary2100::Generators::InstallGenerator.start(["--quiet"], destination_root: root)
  end

  def test_writes_tailwinds_entry_where_propshaft_does_not_serve_it
    in_host_app do |root|
      ComponentLibrary2100.write_tailwind_entry(root)

      assert_match %r{@import ".+/component_library_2100/engine\.css";}, File.read(File.join(root, "app/assets/tailwind/component_library_2100.css"))
      assert_not File.exist?(File.join(root, "app/assets/builds/component_library_2100.css"))
    end
  end

  def test_install_imports_the_entry_next_to_the_host_stylesheet
    in_host_app do |root|
      install(root)

      css = File.read(File.join(root, "app/assets/tailwind/application.css"))
      assert_includes css, %(@import "tailwindcss";\n@import "./component_library_2100.css";)
      assert File.exist?(File.join(root, "app/assets/tailwind/component_library_2100.css"))
    end
  end

  def test_install_ignores_the_generated_entry
    in_host_app do |root|
      install(root)

      assert_includes File.read(File.join(root, ".gitignore")), "/app/assets/tailwind/component_library_2100.css"
    end
  end

  def test_install_registers_the_stimulus_controllers
    in_host_app do |root|
      FileUtils.mkdir_p(File.join(root, "app/javascript/controllers"))
      File.write(File.join(root, "app/javascript/controllers/index.js"), %(import { application } from "controllers/application"\n))
      install(root)

      assert_includes File.read(File.join(root, "app/javascript/controllers/index.js")), "registerComponentLibrary2100(application)"
    end
  end

  def test_running_install_twice_changes_nothing_the_second_time
    in_host_app do |root|
      FileUtils.mkdir_p(File.join(root, "app/javascript/controllers"))
      File.write(File.join(root, "app/javascript/controllers/index.js"), %(import { application } from "controllers/application"\n))
      install(root)
      files = %w[app/assets/tailwind/application.css .gitignore app/javascript/controllers/index.js]
      before = files.to_h { |file| [file, File.read(File.join(root, file))] }

      install(root)

      files.each { |file| assert_equal before[file], File.read(File.join(root, file)), file }
    end
  end

  # Rails looks a generator up by the path its name implies, then by the class's namespace.
  # This runs in a fresh process because the file required above would otherwise already be loaded.
  def test_generators_resolve_by_their_documented_names
    script = <<~RUBY
      require "rails/generators"
      %w[install eject].each do |name|
        found = Rails::Generators.find_by_namespace("component_library_2100", nil, name)
        abort "component_library_2100:\#{name} not found" unless found
      end
    RUBY
    output = IO.popen([RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", script], err: [:child, :out], &:read)

    assert $?.success?, output
  end

  def test_rake_install_runs_the_generator
    require "rake"
    rake = Rake::Application.new
    Rake.with_application(rake) do
      Rake::Task.define_task(:environment)
      load File.expand_path("../lib/tasks/component_library_2100.rake", __dir__)
    end

    in_host_app do |root|
      original = Rails.application.config.root
      Rails.application.config.root = root
      capture_io { rake["component_library_2100:install"].invoke }
    ensure
      Rails.application.config.root = original

      assert_includes File.read(File.join(root, "app/assets/tailwind/application.css")), %(@import "./component_library_2100.css";)
    end
  end
end
