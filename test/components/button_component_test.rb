require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_renders_a_button_by_default
    render_inline(ButtonComponent.new) { "Save" }

    assert_selector "button[type=button].bg-primary.text-primary-on", text: "Save"
  end

  def test_renders_a_link_with_href
    render_inline(ButtonComponent.new(href: "/pricing", variant: :success)) { "Pricing" }

    assert_selector "a[href='/pricing'].bg-success", text: "Pricing"
  end

  def test_outline_and_size
    render_inline(ButtonComponent.new(outline: true, size: :lg, variant: :danger)) { "Delete" }

    assert_selector "button.text-danger.border-danger.py-2"
    assert_no_selector "button.bg-danger"
  end

  def test_disabled_button_and_link
    render_inline(ButtonComponent.new(disabled: true)) { "Off" }
    assert_selector "button[disabled]"

    render_inline(ButtonComponent.new(href: "/x", disabled: true)) { "Off" }
    assert_selector "a[aria-disabled='true'][tabindex='-1']"
  end

  def test_rejects_unknown_size
    assert_raises(ArgumentError) { render_inline(ButtonComponent.new(size: :huge)) { "x" } }
  end
end
