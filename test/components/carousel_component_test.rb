require "test_helper"

class CarouselComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def render_carousel(**options)
    render_inline(CarouselComponent.new(**options)) do |carousel|
      carousel.with_slide { "One" }
      carousel.with_slide { "Two" }
      carousel.with_slide { "Three" }
    end
  end

  def test_is_a_labelled_carousel_region_wired_to_the_controller
    render_carousel(label: "Highlights")

    assert_selector "[role=group][aria-roledescription=carousel][aria-label=Highlights][data-controller='cl-carousel']"
  end

  def test_first_slide_is_active_by_default
    render_carousel

    assert_selector "[data-cl-carousel-target=slide][data-active]", count: 1
    assert_selector "[aria-roledescription=slide]", count: 3
    assert_selector "[data-active]", text: "One"
  end

  def test_an_explicit_active_slide_wins
    render_inline(CarouselComponent.new) do |carousel|
      carousel.with_slide { "One" }
      carousel.with_slide(active: true) { "Two" }
    end

    assert_selector "[data-active]", text: "Two"
    assert_selector "[data-active]", count: 1
  end

  def test_indicators_mark_the_active_slide
    render_carousel

    assert_selector "[data-cl-carousel-target=indicator]", count: 3
    assert_selector "[data-cl-carousel-target=indicator][aria-current=true]", count: 1
  end

  def test_indicators_can_be_turned_off
    render_carousel(indicators: false)

    assert_no_selector "[data-cl-carousel-target=indicator]"
  end

  def test_controls_render_by_default_and_can_be_turned_off
    render_carousel

    assert_selector "button[data-action='cl-carousel#prev'][aria-label=Previous]"
    assert_selector "button[data-action='cl-carousel#next'][aria-label=Next]"

    render_carousel(controls: false)
    assert_no_selector "button[data-action='cl-carousel#next']"
  end

  def test_ride_and_wrap_flow_to_data_values
    render_carousel(ride: true, wrap: false, interval: 3000)

    assert_selector "[data-cl-carousel-ride-value=true]"
    assert_selector "[data-cl-carousel-wrap-value=false]"
    assert_selector "[data-cl-carousel-interval-value='3000']"
  end

  def test_captions_render
    render_inline(CarouselComponent.new) do |carousel|
      carousel.with_slide(caption_title: "Title", caption_text: "Body") { "img" }
    end

    assert_selector "h5", text: "Title"
    assert_selector "p", text: "Body"
  end

  def test_per_slide_interval
    render_inline(CarouselComponent.new) do |carousel|
      carousel.with_slide(interval: 1000) { "One" }
    end

    assert_selector "[data-cl-carousel-target=slide][data-interval='1000']"
  end

  def test_class_override_on_the_root
    render_inline(CarouselComponent.new(class: "max-w-lg")) do |carousel|
      carousel.with_slide { "One" }
    end

    assert_selector "div.max-w-lg[data-controller='cl-carousel']"
  end
end
