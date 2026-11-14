require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_wraps_content_in_body_and_renders_slots_in_order
    render_inline(CardComponent.new) do |card|
      card.with_header { "Head" }
      card.with_footer(class: "text-sm") { "Foot" }
      "Body"
    end

    assert_selector ".border > .border-b", text: "Head"
    assert_selector ".flex-auto.p-4", text: "Body"
    assert_selector ".border-t.text-sm", text: "Foot"
  end

  def test_body_false_skips_wrapper
    render_inline(CardComponent.new(body: false)) { "Raw" }

    assert_no_selector ".flex-auto"
    assert_text "Raw"
  end

  def test_images
    render_inline(CardComponent.new) do |card|
      card.with_image_top(src: "/a.jpg", alt: "A")
      card.with_image_bottom(src: "/b.jpg")
      "x"
    end

    assert_selector "img[src='/a.jpg'][alt=A]"
    assert_selector "img[src='/b.jpg']"
  end

  def test_no_animation_by_default
    render_inline(CardComponent.new) { "Content" }

    assert_no_selector "[class~='duration-200']"
  end

  def test_pop_animation
    render_inline(CardComponent.new(animation: :pop)) { "Content" }

    assert_selector "div[class~='transition-transform'][class~='hover:scale-[1.02]'][class~='motion-reduce:transition-none']"
  end

  def test_lift_animation
    render_inline(CardComponent.new(animation: "lift")) { "Content" }

    assert_selector "div[class~='hover:-translate-y-1'][class~='motion-reduce:transition-none']"
  end

  def test_fade_animation
    render_inline(CardComponent.new(animation: :fade)) { "Content" }

    assert_selector "div[class~='transition-opacity'][class~='hover:opacity-90'][class~='motion-reduce:transition-none']"
  end

  def test_unknown_animation_raises
    error = assert_raises(ArgumentError) { render_inline(CardComponent.new(animation: :spin)) { "Content" } }

    assert_match "Unknown animation :spin", error.message
  end

  def test_media_renders_arbitrary_content_with_an_aspect_ratio
    render_inline(CardComponent.new) do |card|
      card.with_media(aspect: :video, class: "bg-black") { "<video src='/a.mp4'></video>".html_safe }
      "Body"
    end

    assert_selector ".border > div.aspect-video.overflow-hidden.bg-black > video"
    assert_selector ".aspect-video + .flex-auto", text: "Body"
  end

  def test_media_aspects
    {square: "aspect-square", auto: nil}.each do |aspect, css|
      render_inline(CardComponent.new) { |card| card.with_media(aspect: aspect) { "x" } }
      assert_selector "div.overflow-hidden", text: "x"
      assert_selector "div.#{css}" if css
      assert_no_selector "div[class*='aspect-']" unless css
    end

    render_inline(CardComponent.new) { |card| card.with_media(aspect: "4/3") { "x" } }
    assert_selector "div.overflow-hidden[style='aspect-ratio: 4/3']"

    assert_raises(ArgumentError) { render_inline(CardComponent.new) { |card| card.with_media(aspect: :wide) { "x" } } }
  end

  def test_href_makes_the_card_a_stretched_link
    render_inline(CardComponent.new(href: "/posts/1", link_label: "Launch post", class: "w-72")) do |card|
      card.with_footer { "Foot" }
      "Body"
    end

    assert_selector "div.relative.w-72 > a[href='/posts/1'][aria-label='Launch post'].absolute.inset-0"
    assert_selector "a", count: 1
    assert_no_selector "a *"
    assert_selector "div[class~='has-[a:focus-visible]:ring-2']"
  end

  def test_nested_controls_stay_outside_the_link
    render_inline(CardComponent.new(href: "/posts/1", link_label: "Launch post")) do
      "<button class='relative z-10'>Archive</button>".html_safe
    end

    assert_selector "a button", count: 0
    assert_selector ".flex-auto button.relative.z-10", text: "Archive"
  end

  def test_href_needs_a_link_label
    error = assert_raises(ArgumentError) { render_inline(CardComponent.new(href: "/x")) { "Body" } }

    assert_match "link_label", error.message
  end

  def test_card_without_href_has_no_link
    render_inline(CardComponent.new) { "Body" }

    assert_no_selector "a"
  end
end
