require "test_helper"

class FieldCounterTest < ViewComponent::TestCase
  include ComponentLibrary2100
  include ActionView::Helpers::TagHelper

  def field(counter, **options)
    render_inline(FormFieldComponent.new(control_id: "bio", label: "Bio", counter: counter, **options)) do |f|
      tag.textarea(**f.control_options)
    end
  end

  def test_max_renders_the_rule_in_the_hint
    field({max: 2000})

    assert_selector "#bio-hint", text: "Up to 2,000 characters."
    assert_selector "textarea[aria-describedby='bio-hint'][data-cl-counter-target=input]"
    assert_selector "div[data-controller=cl-counter][data-cl-counter-max-value='2000']"
    assert_no_selector "[data-cl-counter-min-value]"
  end

  def test_min_renders_the_rule_in_the_hint
    field({min: 12})

    assert_selector "#bio-hint", text: "At least 12 characters."
    assert_selector "div[data-cl-counter-min-value='12']"
  end

  def test_min_and_max_and_your_own_hint
    field({min: 10, max: 20}, hint: "Say something.")

    assert_selector "#bio-hint", text: "Say something. Between 10 and 20 characters."
  end

  def test_live_region_is_separate_polite_and_outside_the_description
    field({max: 5})

    assert_selector "[role=status][aria-live=polite].sr-only[data-cl-counter-target=status]", visible: :all
    assert_selector "[aria-hidden=true][data-cl-counter-target=count]", visible: :all
    assert_no_selector "#bio-hint [data-cl-counter-target]", visible: :all
    assert_no_selector "textarea[aria-invalid]"
  end

  def test_custom_messages_and_html_mode
    field({max: 5, html: true, hint: "Keep it short.", left: "%{count} left"})

    assert_selector "#bio-hint", text: "Keep it short."
    assert_selector "div[data-cl-counter-html-value=true][data-cl-counter-left-message-value='%{count} left']"
  end

  def test_without_a_counter_nothing_is_added
    field(nil)

    assert_no_selector "[data-controller]"
    assert_no_selector "textarea[data-cl-counter-target]"
    assert_no_selector "[aria-describedby]"
  end

  def test_a_counter_needs_a_rule_and_known_options
    assert_raises(ArgumentError) { field({}) }
    assert_raises(ArgumentError) { field({max: 1, bogus: 2}) }
  end

  def test_server_error_still_sets_aria_invalid
    field({max: 5}, error: "is too long")

    assert_selector "textarea[aria-invalid=true][aria-describedby='bio-error bio-hint']"
  end
end
