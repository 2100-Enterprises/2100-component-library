require "test_helper"

class RangeComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_default_renders_a_range_input
    render_inline(RangeComponent.new(name: "volume", value: 40, min: 0, max: 100, step: 5))

    assert_selector "input[type=range][name=volume][value='40'][min='0'][max='100'][step='5']"
  end

  def test_generates_an_id_when_none_given
    render_inline(RangeComponent.new(name: "x"))

    assert_selector "input[type=range][id^='range-']"
  end

  def test_keeps_a_given_id
    render_inline(RangeComponent.new(id: "vol"))

    assert_selector "input#vol[type=range]"
  end

  def test_label_renders_and_points_at_the_input
    render_inline(RangeComponent.new(id: "vol", label: "Volume"))

    assert_selector "label[for=vol]", text: "Volume"
  end

  def test_hint_is_wired_with_aria_describedby
    render_inline(RangeComponent.new(id: "vol", hint: "0 to 100"))

    assert_selector "input[aria-describedby='vol-hint']"
    assert_selector "#vol-hint", text: "0 to 100"
  end

  def test_disabled
    render_inline(RangeComponent.new(disabled: true))

    assert_selector "input[type=range][disabled]"
  end

  def test_bare_input_without_label_or_hint
    render_inline(RangeComponent.new)

    assert_no_selector "label"
  end

  def test_class_override_is_merged_onto_the_input
    render_inline(RangeComponent.new(class: "max-w-xs"))

    assert_selector "input.max-w-xs[type=range]"
  end
end
