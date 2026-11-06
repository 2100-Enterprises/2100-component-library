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
end
