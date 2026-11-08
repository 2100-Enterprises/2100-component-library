require "test_helper"

class ChipComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_a_chip_without_remove_is_a_static_span
    render_inline(ChipComponent.new(label: "Draft"))

    assert_selector "span", text: "Draft"
    assert_no_selector "a"
    assert_no_selector "button"
  end

  def test_label_can_come_from_the_block
    render_inline(ChipComponent.new) { "PDF" }

    assert_selector "span", text: "PDF"
  end

  def test_remove_url_renders_a_named_link
    render_inline(ChipComponent.new(label: "Open", remove: "/projects"))

    assert_selector "a[href='/projects'][aria-label='Remove Open']"
    assert_no_selector "form"
  end

  def test_remove_with_a_non_get_method_renders_a_form_and_button
    render_inline(ChipComponent.new(label: "Ada", remove: {href: "/members/1", method: :delete, params: {from: "x"}}))

    assert_selector "form[action='/members/1'][method=post] input[name=_method][value=delete]", visible: :all
    assert_selector "form input[name=from][value=x]", visible: :all
    assert_selector "form button[type=submit][aria-label='Remove Ada']"
  end

  def test_a_get_method_stays_a_link
    render_inline(ChipComponent.new(label: "Open", remove: {href: "/p", method: :get}))

    assert_selector "a[href='/p']"
    assert_no_selector "form"
  end

  def test_custom_remove_label
    render_inline(ChipComponent.new(label: "Open", remove: {href: "/p", label: "Clear status filter"}))

    assert_selector "a[aria-label='Clear status filter']"
  end

  def test_remove_name_uses_block_text
    render_inline(ChipComponent.new(remove: "/p")) { "<b>PDF</b>".html_safe }

    assert_selector "a[aria-label='Remove PDF']"
  end

  def test_variants
    render_inline(ChipComponent.new(label: "Bad", variant: :danger))
    assert_selector "span.bg-danger-subtle"

    assert_raises(ArgumentError) { render_inline(ChipComponent.new(label: "x", variant: :nope)) }
  end

  def test_icon_slot_is_hidden_from_assistive_tech
    render_inline(ChipComponent.new(label: "Ada")) { |chip| chip.with_icon { "i" } }

    assert_selector "span[aria-hidden=true]", text: "i"
  end

  def test_html_options_pass_through
    render_inline(ChipComponent.new(label: "Ada", id: "c1"))

    assert_selector "span#c1"
  end
end

class ChipGroupComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_renders_a_labelled_list_of_chips
    render_inline(ChipGroupComponent.new(label: "Active filters")) do |group|
      group.with_chip(label: "Open", remove: "/a")
      group.with_chip(label: "Ada", variant: :primary)
    end

    assert_selector "ul[aria-label='Active filters'] > li", count: 2
    assert_selector "li:first-child a[aria-label='Remove Open']"
    assert_selector "li:last-child span.bg-primary-subtle", text: "Ada"
  end
end
