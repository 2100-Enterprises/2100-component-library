require "minitest/autorun"
require "yaml"

class PrTriageWorkflowTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def workflow = YAML.load_file(File.join(ROOT, ".github/workflows/pr-triage.yml"))

  def jobs = workflow.fetch("jobs")

  # YAML reads the bare key "on" as true. These triggers run development's copy of the
  # workflow, which is what stops a PR rewriting its own triage.
  def test_runs_only_from_triggers_a_pr_cant_rewrite
    assert_equal %w[pull_request_target workflow_run], workflow.fetch(true).keys.sort
    ci = YAML.load_file(File.join(ROOT, ".github/workflows/ci.yml")).fetch("name")
    assert_equal [ci], workflow.dig(true, "workflow_run", "workflows")
  end

  def test_never_checks_out_a_prs_code
    checkouts = jobs.values.flat_map { |job| job.fetch("steps") }.select { |step| step["uses"].to_s.start_with?("actions/checkout") }

    assert_equal jobs.size, checkouts.size
    checkouts.each { |step| assert_equal({"ref" => "development", "persist-credentials" => false}, step["with"]) }
  end

  def test_advances_only_after_a_successful_ci_run_on_a_pr
    condition = jobs.dig("advance", "if")
    assert_includes condition, "workflow_run.conclusion == 'success'"
    assert_includes condition, "workflow_run.event == 'pull_request'"
  end

  def test_grants_nothing_by_default
    assert_equal({}, workflow.fetch("permissions"))
    assert_equal({"contents" => "read", "issues" => "write", "pull-requests" => "write"}, jobs.dig("human_review", "permissions"))
    assert_equal({"contents" => "write", "issues" => "write", "pull-requests" => "write"}, jobs.dig("advance", "permissions"))
  end

# A stacked PR retargeted to development has to be checked again, or its skipped check
# stays green.
def test_rechecks_a_pr_retargeted_to_development
  assert_includes workflow.dig(true, "pull_request_target", "types"), "edited"
end

def test_passes_the_event_action_to_the_check
    step = jobs.dig("human_review", "steps").last
    assert_equal "${{ github.event.action }}", step.dig("env", "EVENT_ACTION")
  end
end
