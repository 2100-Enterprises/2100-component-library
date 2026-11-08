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

  def test_centres_its_label_in_a_box_taller_than_the_text
    render_inline(ButtonComponent.new(class: "min-h-11")) { "Edit plan" }

    assert_selector "button.inline-flex.items-center.justify-center.min-h-11"
    assert_no_selector "button.inline-block"
    assert_no_selector "button.align-middle"
  end

  def test_uses_a_medium_weight
    render_inline(ButtonComponent.new) { "Save" }

    assert_selector "button.font-medium"
    assert_no_selector "button.font-normal"
  end

  def test_every_kind_of_button_has_the_same_focus_ring
    [{}, {outline: true}, {variant: :danger}, {variant: :success, outline: true}, {variant: :link}, {href: "/x"}].each do |options|
      render_inline(ButtonComponent.new(**options)) { "Go" }
      classes = page.first("a, button")[:class].split

      assert_equal ButtonComponent::FOCUS.split, classes.grep(/\Afocus-visible:/), options.inspect
    end
  end

  def test_a_dropdown_caret_is_spaced_by_the_gap
    render_inline(DropdownComponent.new) do |menu|
      menu.with_trigger { "Actions" }
      menu.with_item("Edit", href: "/edit")
    end

    assert_selector "button.inline-flex.gap-1\\.5"
    assert_no_selector "button[class*='after:ml-']"
  end

  def test_rejects_unknown_size
    assert_raises(ArgumentError) { render_inline(ButtonComponent.new(size: :huge)) { "x" } }
  end
end
