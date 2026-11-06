require "test_helper"

class TableAndGroupTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_table_options_become_classes
    render_inline(TableComponent.new(striped: true, hover: true, small: true)) { "<tbody></tbody>".html_safe }

    assert_selector "table.w-full"
    assert_selector "table[class*='nth-of-type(odd)'][class*=':hover']"
    assert_selector "table[class*=':p-1']"
    assert_no_selector "table[class*=':p-2']"
  end

  def test_responsive_wraps_table
    render_inline(TableComponent.new(responsive: :md)) { "" }

    assert_selector "div.max-md\\:overflow-x-auto > table"
  end

  def test_button_group_layout
    render_inline(ButtonGroupComponent.new(vertical: true, aria: {label: "Actions"})) { "x" }

    assert_selector "div[role=group][aria-label=Actions].flex-col"
  end

  def test_badge_pill
    render_inline(BadgeComponent.new(pill: true, variant: :warning)) { "9" }

    assert_selector "span.rounded-full.bg-warning.text-warning-on", text: "9"
  end
end
