require "test_helper"

# Behaviour shared by every component, exercised through Button and Alert.
class BaseBehaviourTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_class_override_replaces_conflicting_utilities
    render_inline(ButtonComponent.new(class: "px-8")) { "Go" }

    assert_selector "button.px-8"
    assert_no_selector "button.px-3"
  end

  def test_passes_through_html_attributes
    render_inline(BadgeComponent.new(id: "count", data: {role: "badge"})) { "4" }

    assert_selector "span#count[data-role='badge']", text: "4"
  end

  def test_data_controller_is_concatenated_not_replaced
    render_inline(AlertComponent.new(dismissible: true, data: {controller: "mine"})) { "Hi" }

    assert_selector "div[data-controller='cl-dismiss mine']"
  end

  def test_unknown_variant_raises_with_options
    error = assert_raises(ArgumentError) { render_inline(BadgeComponent.new(variant: :nope)) { "x" } }

    assert_match(/Unknown variant :nope.*primary/, error.message)
  end

  def test_helpers_render_components
    html = vc_test_controller.view_context.ui_badge("New", variant: :info)

    assert_includes html, "New"
    assert_includes html, "bg-info"
  end
end
