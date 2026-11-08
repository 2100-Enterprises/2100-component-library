require "test_helper"

class TableCaptionTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_caption_is_the_first_child_of_the_table
    render_inline(TableComponent.new) do |table|
      table.with_caption { "Clients" }
      "<tbody><tr><td>x</td></tr></tbody>".html_safe
    end

    assert_selector "table > caption:first-child", text: "Clients"
    assert_selector "table > caption + tbody"
    assert_no_selector "caption.sr-only"
  end

  def test_caption_text_argument
    render_inline(TableComponent.new) { |table| table.with_caption("Clients") }

    assert_selector "table > caption", text: "Clients"
  end

  def test_hidden_caption_is_screen_reader_only
    render_inline(TableComponent.new) do |table|
      table.with_caption(visible: false) { "Clients" }
      "<tbody></tbody>".html_safe
    end

    assert_selector "table > caption.sr-only", text: "Clients"
  end

  def test_caption_stays_inside_the_responsive_table
    render_inline(TableComponent.new(responsive: true)) { |table| table.with_caption { "Clients" } }

    assert_selector "div > table > caption:first-child", text: "Clients"
  end

  def test_table_without_caption_is_unchanged
    render_inline(TableComponent.new) { "<tbody></tbody>".html_safe }

    assert_no_selector "caption"
    assert_selector "table > tbody:first-child"
  end

  def test_header_cell_defaults_to_column_scope
    render_inline(TableHeaderComponent.new) { "Name" }

    assert_selector "th[scope=col]", text: "Name"
  end

  def test_header_cell_row_scope
    render_inline(TableHeaderComponent.new(scope: :row, class: "w-1/4")) { "Ada" }

    assert_selector "th[scope=row].w-1\\/4", text: "Ada"
  end

  def test_header_cell_rejects_unknown_scope
    assert_raises(ArgumentError) { TableHeaderComponent.new(scope: :diagonal) }
  end
end
