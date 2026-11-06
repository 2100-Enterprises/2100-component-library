require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_renders_alert_with_variant
    render_inline(AlertComponent.new(variant: :danger)) { "Broken" }

    assert_selector "div[role=alert].bg-danger-subtle.text-danger-emphasis", text: "Broken"
    assert_no_selector "button"
  end

  def test_dismissible_adds_close_button_wired_to_stimulus
    render_inline(AlertComponent.new(dismissible: true)) { "Hi" }

    assert_selector "div[data-controller='cl-dismiss'].pe-12"
    assert_selector "button[aria-label=Close][data-action='cl-dismiss#close']"
  end
end
