require "test_helper"

# Data-display extras: Skeleton and DescriptionList.
class DataDisplayTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_skeleton_single_block_is_decorative_and_sizeable
    render_inline(SkeletonComponent.new(shape: :block, class: "h-40"))

    assert_selector "div[aria-hidden=true].animate-pulse.bg-surface-muted.h-40"
    assert_selector "div.rounded-ui"
  end

  def test_skeleton_multiline_draws_rows_with_a_short_last_line
    render_inline(SkeletonComponent.new(lines: 3, class: "max-w-md"))

    assert_selector "div[aria-hidden=true].flex.flex-col.max-w-md > div.animate-pulse", count: 3
    assert_selector "div.animate-pulse.w-3\\/4", count: 1
  end

  def test_skeleton_circle_shape
    render_inline(SkeletonComponent.new(shape: :circle))

    assert_selector "div.rounded-full.size-12[aria-hidden=true]"
  end

  def test_skeleton_rejects_an_unknown_shape
    assert_raises(ArgumentError) { SkeletonComponent.new(shape: :blob) }
  end

  def test_description_list_renders_terms_and_descriptions
    render_inline(DescriptionListComponent.new) do |dl|
      dl.with_item(term: "Email", description: "ada@example.com")
      dl.with_item(term: "Status") { "Active" }
    end

    assert_selector "dl > div > dt.text-secondary", text: "Email"
    assert_selector "dl > div > dd", text: "ada@example.com"
    assert_selector "dd", text: "Active"
  end

  def test_description_list_inline_layout_and_dividers
    render_inline(DescriptionListComponent.new(layout: :inline)) do |dl|
      dl.with_item(term: "A", description: "1")
      dl.with_item(term: "B", description: "2")
    end

    assert_selector "div.sm\\:grid.sm\\:grid-cols-3", count: 2
    assert_selector "dd.sm\\:col-span-2", count: 2
    assert_selector "div.border-t.first\\:border-t-0", count: 2
  end

  def test_description_list_without_dividers
    render_inline(DescriptionListComponent.new(dividers: false)) do |dl|
      dl.with_item(term: "A", description: "1")
    end

    assert_no_selector "div.border-t"
  end

  def test_description_list_rejects_an_unknown_layout
    assert_raises(ArgumentError) { DescriptionListComponent.new(layout: :zigzag) }
  end
end
