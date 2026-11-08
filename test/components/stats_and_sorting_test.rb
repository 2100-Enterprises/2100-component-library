require "test_helper"

# Stat, Stats and SortHeader.
class StatsAndSortingTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_stat_is_a_description_list_card
    render_inline(StatComponent.new(label: "Clients", value: "48", hint: "Active this month"))

    assert_selector "dl.p-4.border.rounded-ui > dt", text: "Clients"
    assert_selector "dl > dd.text-3xl", text: "48"
    assert_selector "dl > dd.text-secondary", text: "Active this month"
  end

  def test_stat_trend_up_is_green_with_an_arrow_and_screen_reader_text
    render_inline(StatComponent.new(label: "Revenue", value: "$12,400", change: "8%", trend: :up))

    change = page.find("dd.text-success")
    assert_includes change.text, "8%"
    assert_selector "dd.text-success svg[aria-hidden=true]"
    assert_selector "dd.text-success span.sr-only", text: "Increased by"
  end

  def test_stat_variant_overrides_the_trend_colour
    render_inline(StatComponent.new(label: "Costs", value: "$3,100", change: "4%", trend: :up, variant: :danger))

    assert_selector "dd.text-danger span.sr-only", text: "Increased by"
    assert_no_selector "dd.text-success"
  end

  def test_stat_flat_trend_has_no_arrow
    render_inline(StatComponent.new(label: "Churn", value: "2%", change: "0%", trend: :flat))

    assert_selector "dd.text-secondary span.sr-only", text: "Unchanged:"
    assert_no_selector "dd svg"
  end

  def test_stat_without_card_and_bad_trend
    render_inline(StatComponent.new(label: "A", value: "1", card: false))
    assert_no_selector "dl.border"
    assert_raises(ArgumentError) { StatComponent.new(label: "A", value: "1", trend: :sideways) }
  end

  def test_stats_grid_columns_and_label
    render_inline(StatsComponent.new(columns: 4, label: "Overview")) do |stats|
      stats.with_stat(label: "A", value: "1")
      stats.with_stat(label: "B", value: "2")
    end

    assert_selector "section[aria-label=Overview].grid.sm\\:grid-cols-2.lg\\:grid-cols-4 > dl", count: 2
    assert_raises(ArgumentError) { StatsComponent.new(columns: 5) }
  end

  def test_stats_without_label_is_a_div
    render_inline(StatsComponent.new) { |s| s.with_stat(label: "A", value: "1") }

    assert_selector "div.grid.lg\\:grid-cols-3 > dl"
    assert_no_selector "section"
  end

  def test_sort_header_sorted_column_has_aria_sort_and_arrow
    render_inline(SortHeaderComponent.new(href: "/clients?sort=name&dir=desc", direction: :asc)) { "Name" }

    assert_selector "th[scope=col][aria-sort=ascending].text-left > a[href='/clients?sort=name&dir=desc']", text: "Name"
    assert_selector "th a svg[aria-hidden=true]:not(.opacity-40)"
    assert_includes page.find("th a")[:class], "focus-visible:ring-4"
  end

  def test_sort_header_unsorted_column_has_no_aria_sort_and_a_faint_icon
    render_inline(SortHeaderComponent.new(href: "/x", link: {data: {turbo_frame: "list"}})) { "Email" }

    assert_selector "th:not([aria-sort]) > a[data-turbo-frame=list]", text: "Email"
    assert_selector "th a svg.opacity-40"
  end

  def test_sort_header_end_alignment_shows_the_icon_first_but_keeps_label_first_in_the_dom
    render_inline(SortHeaderComponent.new(href: "/x", direction: :desc, align: :end)) { "Total" }

    assert_selector "th.text-right[aria-sort=descending] > a.flex-row-reverse > span:first-child", text: "Total"
    assert_selector "a.flex-row-reverse > span:first-child + svg[aria-hidden=true]"
  end

  def test_sort_header_rejects_bad_options
    assert_raises(ArgumentError) { SortHeaderComponent.new(href: "/x", direction: :up) }
    assert_raises(ArgumentError) { SortHeaderComponent.new(href: "/x", align: :center) }
  end
end
