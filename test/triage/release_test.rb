require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

# Runs the real script in a throwaway project, with a stand-in for gh.
class ReleaseTest < Minitest::Test
  SCRIPT = File.expand_path("../../bin/release", __dir__)
  REPOSITORY = "acme/library"
  COMMIT = "abc123"

  def setup
    @dir = File.realpath(Dir.mktmpdir)
    @stubs = File.join(@dir, "stubs")
    @project = File.join(@dir, "project")
    FileUtils.mkdir_p([@stubs, File.join(@project, "lib/component_library_2100")])
    File.write(File.join(@stubs, "gh"), <<~RUBY)
      #!/usr/bin/env ruby
      if ARGV.first == "release"
        notes = File.read(ARGV[ARGV.index("--notes-file") + 1])
        File.write(ENV.fetch("GH_CALLS"), ARGV.first(9).join(" ") + "\\n" + notes)
        exit
      end
      print ENV.fetch("GH_TAGS")
    RUBY
    File.chmod(0o755, File.join(@stubs, "gh"))
  end

  def teardown = FileUtils.remove_entry(@dir)

  def project(version:, changelog:, tags: ["v0.1.0"])
    File.write(File.join(@project, "lib/component_library_2100/version.rb"), %(module X\n  VERSION = "#{version}"\nend\n))
    File.write(File.join(@project, "CHANGELOG.md"), changelog)
    @tags = [tags.map { |name| {name: name} }].to_json
  end

  def release(command)
    @calls = File.join(@dir, "calls")
    File.write(@calls, "")
    Open3.capture2e({
      "PATH" => "#{@stubs}:#{ENV.fetch("PATH")}", "GH_CALLS" => @calls, "GH_TAGS" => @tags,
      "GITHUB_REPOSITORY" => REPOSITORY, "GITHUB_SHA" => COMMIT
    }, SCRIPT, command, chdir: @project)
  end

  def calls = File.read(@calls)

  CHANGELOG = <<~MD.freeze
    # Changelog

    ## Unreleased

    - Not out yet.

    ## 0.2.0

    - Added a thing.
    - Changed a thing.

    ## 0.1.0

    - First release.
  MD

  def test_publishes_a_new_version_with_only_its_notes
    project(version: "0.2.0", changelog: CHANGELOG)
    output, status = release("publish")
    assert status.success?, output
    assert_includes calls, "release create v0.2.0 --repo #{REPOSITORY} --target #{COMMIT} --title v0.2.0"
    assert_includes calls, "- Added a thing.\n- Changed a thing."
    refute_includes calls, "First release"
    refute_includes calls, "Not out yet"
  end

  def test_does_nothing_when_the_version_has_a_tag
    project(version: "0.1.0", changelog: CHANGELOG)
    %w[check publish].each do |command|
      output, status = release(command)
      assert status.success?, output
      assert_includes output, "already released"
      assert_empty calls
    end
  end

  def test_refuses_a_version_with_no_notes
    project(version: "0.3.0", changelog: CHANGELOG)
    %w[check publish].each do |command|
      output, status = release(command)
      refute status.success?, output
      assert_includes output, "no notes"
      assert_empty calls
    end
  end

  def test_refuses_an_empty_section
    project(version: "0.2.0", changelog: "## 0.2.0\n\n## 0.1.0\n\n- First.\n")
    output, status = release("check")
    refute status.success?, output
    assert_includes output, "no notes"
  end

  def test_refuses_a_version_older_than_the_latest_tag
    project(version: "0.2.0", changelog: CHANGELOG, tags: %w[v0.1.0 v0.10.0])
    output, status = release("publish")
    refute status.success?, output
    assert_includes output, "isn't newer"
    assert_empty calls
  end

  def test_refuses_a_malformed_version
    project(version: "0.2", changelog: CHANGELOG)
    output, status = release("check")
    refute status.success?, output
    assert_includes output, "no X.Y.Z version"
  end

  def test_check_passes_a_valid_bump_without_publishing
    project(version: "0.2.0", changelog: CHANGELOG)
    output, status = release("check")
    assert status.success?, output
    assert_empty calls
  end
end
