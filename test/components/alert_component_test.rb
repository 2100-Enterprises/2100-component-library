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

    assert_selector "div[data-controller='cl-dismiss'] > div[role=alert].pe-12"
    assert_selector "div[data-controller='cl-dismiss'] > button[aria-label=Close][data-action='cl-dismiss#close']"
  end

  def test_dismissible_keeps_close_button_out_of_the_announced_message
    render_inline(AlertComponent.new(dismissible: true)) { "Hi" }

    assert_no_selector "[role=alert] button"
  end

  def test_dismissible_keeps_other_data_attributes_on_the_alert
    render_inline(AlertComponent.new(dismissible: true, data: {controller: "mine", mine_target: "box"})) { "Hi" }

    assert_selector "[role=alert][data-mine-target=box]"
    assert_no_selector "[role=alert][data-controller]"
  end

  def test_dismissible_keeps_html_attributes_on_the_alert
    render_inline(AlertComponent.new(dismissible: true, id: "saved", role: "status", class: "text-lg")) { "Hi" }

    assert_selector "div#saved[role=status].text-lg"
  end
end
