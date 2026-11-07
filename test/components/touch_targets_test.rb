require "test_helper"

class TouchTargetsTest < ViewComponent::TestCase
  include ComponentLibrary2100

  HIT_AREA = "pointer-coarse:before:h-11".freeze

  def classes_of(selector) = page.find(selector, visible: :all)[:class].split

  def test_small_controls_answer_to_44px_on_touch
    render_inline(ButtonComponent.new) { "Save" }
    assert_includes classes_of("button"), HIT_AREA

    render_inline(CloseButtonComponent.new)
    assert_includes classes_of("button"), HIT_AREA

    render_inline(BreadcrumbComponent.new) do |crumbs|
      crumbs.with_item("Home", href: "/")
      crumbs.with_item("Here", active: true)
    end
    assert_includes classes_of("a"), HIT_AREA
  end

  def test_a_positioned_control_keeps_its_position
    render_inline(CloseButtonComponent.new(class: "absolute top-2 end-2"))

    assert_includes classes_of("button"), "absolute"
    assert_not_includes classes_of("button"), "relative"
  end

  def test_the_hit_area_leaves_the_display_alone_so_hidden_buttons_stay_hidden
    render_inline(ButtonComponent.new(class: "hidden sm:inline-block")) { "Menu" }

    assert_includes classes_of("button"), "hidden"
    assert_empty(classes_of("button").grep(/\Apointer-coarse:(inline-)?(flex|block)\z/))
  end

  def test_a_dropdown_trigger_keeps_its_caret
    render_inline(DropdownComponent.new) do |menu|
      menu.with_trigger { "Actions" }
      menu.with_item("Edit", href: "/edit")
    end

    assert_includes classes_of("button"), "after:inline-block"
    assert_includes classes_of("button"), HIT_AREA
  end

  def test_a_dropdown_stays_on_the_screen_and_its_text_wraps
    render_inline(DropdownComponent.new) do |menu|
      menu.with_trigger { "Account" }
      menu.with_header("someone-with-a-long-address@example.com")
      menu.with_item("Sign out", href: "/session")
    end

    assert_includes classes_of("[role=menu]"), "max-w-[calc(100vw-0.5rem)]"
    assert_includes classes_of("[role=presentation]"), "wrap-anywhere"
    assert_includes classes_of("[role=menuitem]"), "wrap-anywhere"
    assert_includes classes_of("[role=menuitem]"), "pointer-coarse:py-2.5"
  end

  def test_page_links_wrap_and_grow_on_touch
    render_inline(PaginationComponent.new) { |pages| pages.with_item("2", href: "?page=2") }

    assert_includes classes_of("ul"), "flex-wrap"
    assert_includes classes_of("a"), "pointer-coarse:min-h-11"
    assert_includes classes_of("a"), "pointer-coarse:min-w-11"
  end

  def test_a_switch_row_is_tall_enough_on_touch
    render_inline(SwitchComponent.new(name: "on", label: "Notifications"))

    assert_includes classes_of("label"), "pointer-coarse:py-2.5"
    assert_includes classes_of("input[type=checkbox]"), "pointer-coarse:mt-3.5"
  end

  def test_inputs_and_selects_are_tall_enough_on_touch
    assert_includes FormFieldComponent::CONTROL.split, "pointer-coarse:min-h-11"
    assert_includes FormFieldComponent::SELECT.split, "pointer-coarse:min-h-11"
    assert_includes FormFieldComponent::TEXTAREA.split, "pointer-coarse:min-h-11"
  end
end
