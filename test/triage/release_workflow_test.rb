require "minitest/autorun"
require "yaml"

class ReleaseWorkflowTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def workflow = YAML.load_file(File.join(ROOT, ".github/workflows/release.yml"))

  def job = workflow.dig("jobs", "release")

  # YAML reads the bare key "on" as true.
  def test_runs_only_for_a_version_change_on_development
    assert_equal ["development"], workflow.dig(true, "push", "branches")
    assert_equal ["lib/component_library_2100/version.rb"], workflow.dig(true, "push", "paths")
  end

  def test_publishes_only_after_ci
    assert_equal "ci", job.fetch("needs")
    assert_equal "./.github/workflows/ci.yml", workflow.dig("jobs", "ci", "uses")
  end

  def test_only_the_publish_job_can_write
    assert_equal({"contents" => "read"}, workflow.fetch("permissions"))
    assert_equal({"contents" => "write"}, job.fetch("permissions"))
  end

  def test_ci_checks_the_release_on_every_pr
    ci = YAML.load_file(File.join(ROOT, ".github/workflows/ci.yml"))
    assert(ci.dig("jobs", "package", "steps").any? { |step| step["run"] == "bin/release check" })
  end
end
