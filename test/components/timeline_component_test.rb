require "test_helper"

class TimelineComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_renders_an_ordered_list_of_events
    render_inline(TimelineComponent.new) do |timeline|
      timeline.with_event(title: "First") { "One" }
      timeline.with_event(title: "Second")
    end

    assert_selector "ol > li", count: 2
    assert_selector "ol > li:first-child", text: "First"
    assert_selector "ol > li:first-child", text: "One"
  end

  def test_time_renders_datetime_attribute_and_readable_text
    render_inline(TimelineComponent.new) do |timeline|
      timeline.with_event(time: Time.utc(2026, 5, 3, 14, 5), title: "Sent")
      timeline.with_event(time: Date.new(2026, 5, 4), title: "Signed")
    end

    assert_selector "time[datetime='2026-05-03T14:05:00Z']", text: "May 3, 2026, 2:05 PM"
    assert_selector "time[datetime='2026-05-04']", text: "May 4, 2026"
  end

  def test_time_label_overrides_text_but_keeps_datetime
    render_inline(TimelineComponent.new) do |timeline|
      timeline.with_event(time: Date.new(2026, 5, 4), time_label: "Yesterday", title: "Signed")
    end

    assert_selector "time[datetime='2026-05-04']", text: "Yesterday"
  end

  def test_markers_are_hidden_from_assistive_technology
    render_inline(TimelineComponent.new) do |timeline|
      timeline.with_event(title: "Plain")
      timeline.with_event(title: "Iconic", icon: "!", variant: :danger)
    end

    assert_selector "li [aria-hidden=true]", count: 2
    assert_no_selector "li [aria-hidden=true]", text: "Iconic"
    assert_selector "li", text: "Iconic"
  end

  def test_icon_slot_renders_inside_the_marker
    render_inline(TimelineComponent.new) do |timeline|
      timeline.with_event(title: "Uploaded") { |event| event.with_icon { "<svg id='up'></svg>".html_safe } }
    end

    assert_selector "[aria-hidden=true] svg#up"
  end

  def test_variant_tints_the_marker_and_rejects_unknown_variants
    render_inline(TimelineComponent.new) { |timeline| timeline.with_event(title: "Done", variant: :success) }

    assert_selector "li [aria-hidden=true].bg-success"
    assert_raises(ArgumentError) do
      render_inline(TimelineEventComponent.new(title: "x", variant: :nope))
    end
  end

  def test_alternate_marks_the_list
    render_inline(TimelineComponent.new(alternate: true)) { |timeline| timeline.with_event(title: "A") }

    assert_selector "ol[data-alternate]"
    assert_selector "li[class*='md:group-data-alternate/timeline']"
  end

  def test_not_alternate_by_default
    render_inline(TimelineComponent.new) { |timeline| timeline.with_event(title: "A") }

    assert_no_selector "ol[data-alternate]"
  end

  def test_label_names_the_list
    render_inline(TimelineComponent.new(label: "Project activity")) { |timeline| timeline.with_event(title: "A") }

    assert_selector "ol[aria-label='Project activity']"
  end

  def test_html_attributes_go_on_the_list
    render_inline(TimelineComponent.new(id: "activity", class: "max-w-lg")) { |timeline| timeline.with_event(title: "A") }

    assert_selector "ol#activity.max-w-lg"
  end

  def test_event_renders_alone_as_a_self_contained_list_item
    render_inline(TimelineEventComponent.new(time: Date.new(2026, 5, 4), title: "File uploaded", variant: :info)) { "report.pdf" }

    assert_selector "li", count: 1
    assert_selector "li [aria-hidden=true]"
    assert_selector "li time[datetime='2026-05-04']"
    assert_selector "li", text: "File uploaded"
    assert_selector "li", text: "report.pdf"
    assert_no_selector "ol"
  end
end
