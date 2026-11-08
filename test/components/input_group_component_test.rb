require "test_helper"

class InputGroupComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_wraps_prepend_text_in_a_styled_span
    render_inline(InputGroupComponent.new) do |group|
      group.with_prepend { "$" }
      group.with_control { "<input type=\"text\">".html_safe }
    end

    assert_selector "div.flex > span.bg-surface-muted", text: "$"
    assert_selector "div.flex > input[type=text]"
  end

  def test_renders_prepend_and_append_around_the_control
    render_inline(InputGroupComponent.new) do |group|
      group.with_prepend { "@" }
      group.with_control { "<input>".html_safe }
      group.with_append { ".com" }
    end

    spans = page.all("span").map(&:text)
    assert_equal ["@", ".com"], spans
    assert_selector "input"
  end

  def test_small_size_shrinks_text_addons
    render_inline(InputGroupComponent.new(size: :sm)) do |group|
      group.with_prepend { "kg" }
      group.with_control { "<input>".html_safe }
    end

    assert_selector "span.text-sm", text: "kg"
  end

  def test_large_size
    render_inline(InputGroupComponent.new(size: :lg)) do |group|
      group.with_prepend { "kg" }
      group.with_control { "<input>".html_safe }
    end

    assert_selector "span.text-lg", text: "kg"
  end

  def test_addon_accepts_attributes
    render_inline(InputGroupComponent.new) do |group|
      group.with_prepend(id: "basic-addon") { "@" }
      group.with_control { "<input>".html_safe }
    end

    assert_selector "span#basic-addon", text: "@"
  end

  def test_class_override_on_the_group
    render_inline(InputGroupComponent.new(class: "mb-4")) do |group|
      group.with_control { "<input>".html_safe }
    end

    assert_selector "div.mb-4.flex"
  end
end
