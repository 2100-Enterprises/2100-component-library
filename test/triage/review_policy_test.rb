require "minitest/autorun"
require_relative "../../script/review_policy"

class ReviewPolicyTest < Minitest::Test
  SENSITIVE = %w[
    .github/dependabot.yml
    .github/workflows/ci.yml
    .rubocop.yml
    Gemfile
    LICENSE
    Rakefile
    SECURITY.md
    app/javascript/component_library_2100/index.js
    bin/pr-triage
    component_library_2100.gemspec
    config/importmap.rb
    gemfiles/oldest.gemfile
    lib/component_library_2100.rb
    lib/component_library_2100/version.rb
    lib/generators/component_library_2100/install/install_generator.rb
    lib/tasks/component_library_2100.rake
    script/review_policy.rb
  ].freeze

  HARMLESS = %w[
    CHANGELOG.md
    README.md
    app/assets/tailwind/component_library_2100/engine.css
    app/components/component_library_2100/button_component.rb
    docs/lib/notes.md
    test/components/button_component_test.rb
  ].freeze

  def policy = ReviewPolicy.new("acme/library")

  def test_sensitive_paths = assert_equal(SENSITIVE, policy.sensitive(SENSITIVE))

  def test_harmless_paths = assert_empty(policy.sensitive(HARMLESS))
end
