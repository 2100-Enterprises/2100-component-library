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
end
