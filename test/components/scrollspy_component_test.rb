require "test_helper"

class ScrollspyComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def render_spy(**options)
    render_inline(ScrollspyComponent.new(**options)) do |spy|
      spy.with_item("Intro", href: "#intro", active: true)
      spy.with_item("Details", href: "#details")
      spy.with_item("Pricing", href: "#pricing")
    end
  end

  def test_is_a_labelled_nav_wired_to_the_controller
    render_spy(label: "On this page")

    assert_selector "nav[aria-label='On this page'][data-controller='cl-scrollspy']"
    assert_selector "nav ul li a", count: 3
  end

  def test_links_point_at_their_sections_and_are_targets
    render_spy

    assert_selector "a[href='#intro'][data-cl-scrollspy-target=link][data-action='cl-scrollspy#click']", text: "Intro"
    assert_selector "a[href='#details']", text: "Details"
  end

  def test_active_item_is_marked_current
    render_spy

    assert_selector "a[aria-current=true]", count: 1
    assert_selector "a[aria-current=true]", text: "Intro"
  end

  def test_offset_and_smooth_flow_to_data_values
    render_spy(offset: 80, smooth: false)

    assert_selector "[data-cl-scrollspy-offset-value='80']"
    assert_selector "[data-cl-scrollspy-smooth-value=false]"
  end

  def test_item_accepts_a_block
    render_inline(ScrollspyComponent.new) do |spy|
      spy.with_item(href: "#a") { "Block label" }
    end

    assert_selector "a[href='#a']", text: "Block label"
  end

  def test_class_override_on_the_nav
    render_inline(ScrollspyComponent.new(class: "sticky top-4")) do |spy|
      spy.with_item("Intro", href: "#intro")
    end

    assert_selector "nav.sticky.top-4"
  end
end
