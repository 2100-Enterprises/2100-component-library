# What counts as a sensitive change, and whether a person has reviewed one. Used by bin/pr-triage.
require "json"
require "open3"
require "time"

class ReviewPolicy
  REVIEWED = "human-reviewed".freeze
  HOLD = "do-not-auto-merge".freeze
  # lib/, config/ and app/javascript/ run inside a consumer's boot, build or browser, and the
  # rest decides what CI checks and what the gem depends on. Anything else stays on
  # development until a person releases it.
  SENSITIVE = %r{\A(?:
    \.github/ |
    \.rubocop\.yml\z |
    Gemfile\z |
    LICENSE\z |
    Rakefile\z |
    SECURITY\.md\z |
    app/javascript/ |
    bin/ |
    config/ |
    gemfiles/ |
    lib/ |
    script/ |
    [^/]+\.gemspec\z
  )}x

  Stop = Class.new(StandardError)

  def initialize(repository)
    @repository = repository
  end

  def sensitive(paths)
    paths.grep(SENSITIVE)
  end

  def held?(pull_request)
    labeled?(pull_request, HOLD)
  end

  # The label has to come after the last commit, so a later push can't ride on an old review.
  # A commit's date is whatever its author says, so bin/pr-triage also takes the label off on
  # every push.
  def reviewed?(pull_request, last_commit_at:)
    return false unless labeled?(pull_request, REVIEWED)

    labeled_at = last_labeled_at(pull_request.fetch("number"))

    !labeled_at.nil? && labeled_at > last_commit_at
  end

  def api(path)
    JSON.parse(gh("repos/#{@repository}/#{path}"))
  end

  def paginated(path)
    JSON.parse(gh("--paginate", "--slurp", "repos/#{@repository}/#{path}")).flatten
  end

  def gh(*arguments)
    run_command("gh", "api", *arguments)
  end

  def run_command(*command)
    output, status = Open3.capture2e(*command)
    raise Stop, "#{command.first(3).join(" ")} failed: #{output.strip}" unless status.success?

    output
  end

  private

  def labeled?(pull_request, name)
    pull_request.fetch("labels").any? { |label| label["name"] == name }
  end

  def last_labeled_at(number)
    labeled = paginated("issues/#{number}/events?per_page=100")
      .select { |event| event["event"] == "labeled" && event.dig("label", "name") == REVIEWED && event.dig("actor", "type") == "User" }

    labeled.map { |event| Time.iso8601(event.fetch("created_at")) }.max
  end
end
