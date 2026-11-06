require "fileutils"
require "json"
require "minitest/autorun"
require "open3"
require "tmpdir"

# Runs the real script with a stand-in for gh that records every change it's asked to make.
class PrTriageTest < Minitest::Test
  SCRIPT = File.expand_path("../../bin/pr-triage", __dir__)
  REPOSITORY = "acme/library"
  HEAD = "abc123"
  SENSITIVE = "lib/component_library_2100.rb"
  COMMIT_TIME = "2026-01-02T12:00:00Z"
  BEFORE_COMMIT = "2026-01-01T12:00:00Z"
  AFTER_COMMIT = "2026-01-03T12:00:00Z"

  MERGE = "api -X PUT -f merge_method=merge -f sha=#{HEAD} repos/#{REPOSITORY}/pulls/1/merge"
  DELETE_BRANCH = "api -X DELETE repos/#{REPOSITORY}/git/refs/heads/feature/thing"
  READY = "pr ready 1 --repo #{REPOSITORY}"
  NEEDED = "api -X POST -f labels[]=needs-human-review repos/#{REPOSITORY}/issues/1/labels"
  REMOVE_NEEDED = "api -X DELETE repos/#{REPOSITORY}/issues/1/labels/needs-human-review"
  REMOVE_REVIEWED = "api -X DELETE repos/#{REPOSITORY}/issues/1/labels/human-reviewed"

  def setup
    @stubs = File.realpath(Dir.mktmpdir)
    @responses = {}
    File.write(File.join(@stubs, "gh"), <<~RUBY)
      #!/usr/bin/env ruby
      require "json"
      if ARGV.first == "pr" || ARGV.include?("-X")
        File.write(ENV.fetch("GH_CALLS"), ARGV.join(" ") + "\\n", mode: "a")
        exit
      end
      responses = JSON.parse(File.read(ENV.fetch("GH_RESPONSES")))
      endpoint = ARGV.last
      abort "no stub for \#{endpoint}" unless responses.key?(endpoint)
      puts responses[endpoint].to_json
    RUBY
    File.chmod(0o755, File.join(@stubs, "gh"))
  end

  def teardown = FileUtils.remove_entry(@stubs)

  def pull_request(paths: ["README.md"], labels: [], events: [], draft: true, listed: {}, files: nil)
    files ||= paths.map { |path| {filename: path} }
    summary = {
      number: 1, state: "open", head: {sha: HEAD, ref: "feature/thing", repo: {full_name: REPOSITORY}}, base: {ref: "development"}
    }.merge(listed)

    @responses["repos/#{REPOSITORY}/commits/#{HEAD}/pulls"] = [summary]
    @responses["repos/#{REPOSITORY}/commits/#{HEAD}"] = {commit: {committer: {date: COMMIT_TIME}}}
    @responses["repos/#{REPOSITORY}/pulls/1"] = summary.merge(
      draft: draft, changed_files: files.size, labels: labels.map { |name| {name: name} }
    )
    @responses["repos/#{REPOSITORY}/pulls/1/files?per_page=100"] = [files]
    @responses["repos/#{REPOSITORY}/issues/1/events?per_page=100"] = [events]
    @responses["repos/#{REPOSITORY}/pulls?state=open&base=feature%2Fthing"] = []
  end

  def labeled(at, type: "User")
    {event: "labeled", created_at: at, label: {name: "human-reviewed"}, actor: {type: type}}
  end

  def triage(command, environment = {})
    responses = File.join(@stubs, "responses.json")
    @calls = File.join(@stubs, "calls")
    File.write(responses, @responses.to_json)
    File.write(@calls, "")
    Open3.capture2e({
      "PATH" => "#{@stubs}:#{ENV.fetch("PATH")}", "GH_RESPONSES" => responses, "GH_CALLS" => @calls,
      "GITHUB_REPOSITORY" => REPOSITORY, "HEAD_SHA" => HEAD, "PR_NUMBER" => "1"
    }.merge(environment), SCRIPT, command)
  end

  def calls = File.readlines(@calls, chomp: true)

  def advance
    output, status = triage("advance")
    assert status.success?, output
  end

  def assert_check_fails(message, environment = {})
    output, status = triage("check", environment)
    refute status.success?, output
    assert_includes output, message
  end

  def test_merges_a_harmless_draft
    pull_request
    advance
    assert_equal [READY, MERGE, DELETE_BRANCH], calls
  end

  def test_merges_a_harmless_pr_thats_ready
    pull_request(draft: false)
    advance
    assert_equal [MERGE, DELETE_BRANCH], calls
  end

  def test_keeps_a_branch_that_another_pr_is_based_on
    pull_request(draft: false)
    @responses["repos/#{REPOSITORY}/pulls?state=open&base=feature%2Fthing"] = [{number: 2}]
    advance
    assert_equal [MERGE], calls
  end

  def test_starts_no_deploy
    pull_request
    advance
    refute(calls.any? { |call| call.include?("dispatches") })
  end

  def test_leaves_a_held_pr_as_it_is
    pull_request(labels: ["do-not-auto-merge"])
    advance
    assert_empty calls
  end

  def test_labels_a_sensitive_draft_without_merging
    pull_request(paths: [SENSITIVE])
    advance
    assert_equal [NEEDED, READY], calls
  end

  def test_holds_a_rename_out_of_a_sensitive_path
    pull_request(files: [{filename: "docs/moved.rb", previous_filename: SENSITIVE}])
    advance
    assert_equal [NEEDED, READY], calls
  end

  def test_holds_a_pr_with_more_files_than_github_lists
    pull_request
    @responses["repos/#{REPOSITORY}/pulls/1"][:changed_files] = 3001
    advance
    assert_equal [NEEDED, READY], calls
  end

  def test_leaves_a_reviewed_sensitive_pr_for_a_person_to_merge
    pull_request(paths: [SENSITIVE], labels: %w[needs-human-review human-reviewed], events: [labeled(AFTER_COMMIT)], draft: false)
    advance
    assert_equal [REMOVE_NEEDED], calls
  end

  def test_asks_for_review_again_when_a_commit_follows_the_label
    pull_request(paths: [SENSITIVE], labels: ["human-reviewed"], events: [labeled(BEFORE_COMMIT)], draft: false)
    advance
    assert_equal [NEEDED], calls
  end

  def test_ignores_prs_it_shouldnt_move
    {
      "a fork" => {head: {sha: HEAD, repo: {full_name: "stranger/library"}}},
      "a newer commit" => {head: {sha: "def456", repo: {full_name: REPOSITORY}}},
      "another base" => {base: {ref: "feature"}},
      "a closed PR" => {state: "closed"}
    }.each do |description, listed|
      pull_request(listed: listed)
      advance
      assert_empty calls, description
    end
  end

  def test_merges_nothing_when_github_cant_list_the_files
    pull_request
    @responses.delete("repos/#{REPOSITORY}/pulls/1/files?per_page=100")
    _output, status = triage("advance")
    refute status.success?
    assert_empty calls
  end

  def test_check_passes_a_harmless_pr
    pull_request
    output, status = triage("check")
    assert status.success?, output
    assert_empty calls
  end

  def test_check_fails_a_sensitive_pr_and_names_the_paths
    pull_request(paths: [SENSITIVE])
    assert_check_fails SENSITIVE
  end

  def test_check_fails_when_the_label_came_before_the_last_commit
    pull_request(paths: [SENSITIVE], labels: ["human-reviewed"], events: [labeled(BEFORE_COMMIT)])
    assert_check_fails "Review it"
  end

  def test_check_fails_when_a_bot_added_the_label
    pull_request(paths: [SENSITIVE], labels: ["human-reviewed"], events: [labeled(AFTER_COMMIT, type: "Bot")])
    assert_check_fails "Review it"
  end

  def test_check_passes_a_reviewed_pr_and_takes_off_needs_human_review
    pull_request(paths: [SENSITIVE], labels: %w[needs-human-review human-reviewed], events: [labeled(AFTER_COMMIT)])
    output, status = triage("check")
    assert status.success?, output
    assert_equal [REMOVE_NEEDED], calls
  end

  # A backdated commit looks older than the label, so the date alone can't be trusted.
  def test_a_push_removes_the_review_even_with_a_backdated_commit
    pull_request(paths: [SENSITIVE], labels: ["human-reviewed"], events: [labeled(AFTER_COMMIT)])
    assert_check_fails "Review it", "EVENT_ACTION" => "synchronize"
    assert_equal [REMOVE_REVIEWED], calls
  end

  def test_check_fails_a_held_pr_even_if_its_harmless
    pull_request(labels: ["do-not-auto-merge"])
    assert_check_fails "do-not-auto-merge"
  end
end
