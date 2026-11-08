require "test_helper"

class OverlayAccessibilityTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_offcanvas_title_names_the_dialog
    render_inline(OffcanvasComponent.new(title: "Filters", id: "filters")) { "x" }

    heading = page.find("dialog#filters h2", text: "Filters", visible: :all)
    assert_selector "dialog#filters[aria-labelledby='#{heading[:id]}']", visible: :all
  end

  def test_offcanvas_accepts_an_aria_label_without_a_title
    render_inline(OffcanvasComponent.new(aria: {label: "Cart"})) { "x" }

    assert_selector "dialog[aria-label='Cart']", visible: :all
  end

  def test_offcanvas_accepts_aria_labelledby_without_a_title
    render_inline(OffcanvasComponent.new(aria: {labelledby: "page-title"})) { "x" }

    assert_selector "dialog[aria-labelledby='page-title']", visible: :all
  end

  def test_offcanvas_without_a_name_raises
    error = assert_raises(ArgumentError) { render_inline(OffcanvasComponent.new) { "x" } }
    assert_match(/title:|aria/, error.message)
  end

  def test_navbar_menu_is_named_and_overridable
    render_inline(NavbarComponent.new) { |nav| nav.with_item("Home", href: "/") }
    assert_selector "dialog h2", text: "Menu", visible: :all

    render_inline(NavbarComponent.new(menu_label: "Navigation")) { |nav| nav.with_item("Home", href: "/") }
    assert_selector "dialog h2", text: "Navigation", visible: :all
  end

  def test_built_in_triggers_control_the_dialog_and_report_state
    [ModalComponent.new(title: "T"), OffcanvasComponent.new(title: "T")].each do |component|
      render_inline(component) { |dialog| dialog.with_trigger { "Open" } }

      dialog_id = page.find("dialog", visible: :all)[:id]
      assert dialog_id.present?
      assert_selector "button[aria-controls='#{dialog_id}'][aria-expanded='false'][data-cl-dialog-target='trigger']", text: "Open"
    end
  end

  def test_modal_heading_level_defaults_to_2_and_can_change
    render_inline(ModalComponent.new(title: "T")) { "x" }
    assert_selector "dialog h2", text: "T", visible: :all

    render_inline(ModalComponent.new(title: "T", heading_level: 3)) { "x" }
    assert_selector "dialog h3", text: "T", visible: :all
    assert_no_selector "dialog h2", visible: :all
  end

  def test_offcanvas_heading_level
    render_inline(OffcanvasComponent.new(title: "T", heading_level: 4)) { "x" }

    assert_selector "dialog h4", text: "T", visible: :all
  end

  def test_confirm_dialog_heading_level
    render_inline(ConfirmDialogComponent.new(heading_level: 3))

    assert_selector "dialog h3", text: "Are you sure?", visible: :all
  end

  def test_invalid_heading_levels_raise
    [0, 7, "2", nil].each do |level|
      assert_raises(ArgumentError) { render_inline(ModalComponent.new(title: "T", heading_level: level)) { "x" } }
    end
    assert_raises(ArgumentError) { render_inline(ConfirmDialogComponent.new(heading_level: 9)) }
  end

  def test_modal_description_id_sets_aria_describedby
    render_inline(ModalComponent.new(title: "T", description_id: "help")) { "<p id='help'>Details</p>".html_safe }

    assert_selector "dialog[aria-describedby='help']", visible: :all
  end

  def test_confirm_dialog_is_described_by_its_message
    render_inline(ConfirmDialogComponent.new(id: "confirm-x"))

    assert_selector "dialog[aria-describedby='confirm-x-message']", visible: :all
    assert_selector "#confirm-x-message", visible: :all
  end
end
