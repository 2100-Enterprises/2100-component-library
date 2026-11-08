require "test_helper"

class FloatingLabelComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_wraps_the_control_and_renders_a_floating_label
    render_inline(FloatingLabelComponent.new(label: "Email", control_id: "email")) do
      "<input id=\"email\" placeholder=\" \">".html_safe
    end

    assert_selector "div.relative > input#email"
    assert_selector "div.relative > label[for=email]", text: "Email"
  end

  def test_label_has_the_peer_float_classes
    render_inline(FloatingLabelComponent.new(label: "Name", control_id: "name")) do
      "<input id=\"name\">".html_safe
    end

    assert_selector "label.peer-focus\\:scale-75[for=name]"
  end

  def test_control_constant_includes_peer
    assert_includes FloatingLabelComponent::CONTROL, "peer"
  end

  def test_class_override_on_the_wrapper
    render_inline(FloatingLabelComponent.new(label: "Email", control_id: "email", class: "mb-3")) do
      "<input id=\"email\">".html_safe
    end

    assert_selector "div.relative.mb-3"
  end
end
