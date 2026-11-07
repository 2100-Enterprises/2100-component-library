require "test_helper"

class InteractiveComponentsTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_collapse_links_trigger_and_panel
    render_inline(CollapseComponent.new(id: "more")) do |collapse|
      collapse.with_trigger(variant: :secondary) { "Details" }
      "Hidden text"
    end

    assert_selector "[data-controller='cl-collapse'] button.bg-secondary[aria-controls=more][aria-expanded=false][data-action='cl-collapse#toggle']", text: "Details"
    assert_selector "#more[data-cl-collapse-target=panel]:not([data-open])"
    assert_selector "#more [data-cl-collapse-target=inner][inert]", text: "Hidden text", visible: :all
  end

  def test_collapse_can_start_open
    render_inline(CollapseComponent.new(open: true)) { "Shown" }

    assert_selector "[data-controller='cl-collapse'][data-cl-collapse-open-value=true]"
    assert_selector "[data-cl-collapse-target=panel][data-open]"
    assert_no_selector "[inert]"
  end

  def test_accordion_items_share_a_name_so_the_browser_closes_the_others
    render_inline(AccordionComponent.new) do |accordion|
      accordion.with_item(title: "One", open: true) { "First" }
      accordion.with_item(title: "Two") { "Second" }
    end

    names = page.all("details", visible: :all).map { |details| details[:name] }
    assert_equal 2, names.size
    assert_equal 1, names.uniq.size
    assert names.first.start_with?("accordion-")
    assert_selector "details[open] summary", text: "One"
    assert_selector "details:not([open]) summary", text: "Two"
  end

  def test_accordion_always_open_has_no_group
    render_inline(AccordionComponent.new(always_open: true)) { |accordion| accordion.with_item(title: "One") { "x" } }

    assert_selector "details:not([name])"
  end

  def test_dropdown_wires_trigger_to_a_popover_menu
    render_inline(DropdownComponent.new(placement: "bottom-end")) do |menu|
      menu.with_trigger { "Actions" }
      menu.with_header("Project")
      menu.with_item("Edit", href: "/edit")
      menu.with_item("Archive", data: {action: "archive#run"})
      menu.with_divider
      menu.with_item("Delete", disabled: true)
    end

    assert_selector "[data-controller='cl-popover'][data-cl-popover-placement-value='bottom-end']"
    menu_id = page.find("[role=menu]", visible: :all)[:id]
    assert_selector "button.bg-secondary[popovertarget='#{menu_id}'][aria-haspopup=menu]", text: "Actions"
    assert_selector "[role=menu][popover=auto]", visible: :all
    assert_selector "a[role=menuitem][href='/edit']", text: "Edit", visible: :all
    assert_selector "button[role=menuitem][data-action='click->cl-popover#close archive#run']", text: "Archive", visible: :all
    assert_selector "button[role=menuitem][disabled]", text: "Delete", visible: :all
    assert_selector "[role=separator]", visible: :all
    assert_selector "[role=presentation]", text: "Project", visible: :all
  end

  def test_popover_has_title_and_body
    render_inline(PopoverComponent.new(title: "Heads up", id: "tip")) do |popover|
      popover.with_trigger { "Open" }
      "Body text"
    end

    assert_selector "button[popovertarget=tip]", text: "Open"
    assert_selector "#tip[popover=auto][role=dialog][aria-labelledby='tip-title']", visible: :all
    assert_selector "#tip-title", text: "Heads up", visible: :all
    assert_selector "#tip", text: "Body text", visible: :all
  end

  def test_modal_renders_a_labelled_dialog_with_trigger_and_footer
    render_inline(ModalComponent.new(title: "Sure?", size: :sm, centered: true, static_backdrop: true)) do |modal|
      modal.with_trigger(variant: :danger) { "Delete" }
      modal.with_footer { "Footer" }
      "Body"
    end

    assert_selector "[data-controller='cl-dialog'][data-cl-dialog-locked-value=true]"
    assert_selector "button.bg-danger[data-action='cl-dialog#open']", text: "Delete"
    title_id = page.find("h5", text: "Sure?", visible: :all)[:id]
    assert_selector "dialog[aria-labelledby='#{title_id}'].max-w-\\[300px\\].my-auto", visible: :all
    assert_selector "dialog button[data-action='cl-dialog#close'][aria-label=Close]", visible: :all
    assert_selector "dialog", text: "Body", visible: :all
    assert_selector "dialog .border-t", text: "Footer", visible: :all
  end

  def test_modal_without_title_has_no_header
    render_inline(ModalComponent.new) { "Body" }

    assert_no_selector "dialog h5", visible: :all
    assert_no_selector "dialog[aria-labelledby]", visible: :all
    assert_selector "dialog.mt-7", visible: :all
  end

  def test_offcanvas_docks_to_an_edge_and_reuses_the_modal_markup
    render_inline(OffcanvasComponent.new(title: "Filters", placement: :end)) do |panel|
      panel.with_trigger { "Open" }
      "Body"
    end

    assert_selector "[data-controller='cl-dialog'] dialog.right-0.translate-x-full", visible: :all
    assert_selector "button[data-action='cl-dialog#open']", text: "Open"
    assert_raises(ArgumentError) { render_inline(OffcanvasComponent.new(placement: :middle)) { "x" } }
  end

  def test_tabs_activate_the_first_enabled_tab_by_default
    render_inline(TabsComponent.new) do |tabs|
      tabs.with_tab(title: "Gone", disabled: true) { "A" }
      tabs.with_tab(title: "One") { "B" }
      tabs.with_tab(title: "Two") { "C" }
    end

    assert_selector "[role=tablist] button[role=tab]", count: 3
    assert_selector "button[role=tab][aria-selected=true][tabindex='0']", text: "One"
    assert_selector "button[role=tab][aria-selected=false][tabindex='-1']", count: 2
    assert_selector "button[role=tab][disabled]", text: "Gone"
    assert_selector "[role=tabpanel]:not([hidden])", text: "B"
    assert_selector "[role=tabpanel][hidden]", count: 2, visible: :all
  end

  def test_tabs_link_each_tab_to_its_panel
    render_inline(TabsComponent.new(style: :pills)) do |tabs|
      tabs.with_tab(title: "One", id: "one", active: true) { "B" }
    end

    assert_selector "button#one-tab[aria-controls=one-panel].aria-selected\\:bg-primary"
    assert_selector "#one-panel[role=tabpanel][aria-labelledby=one-tab]"
  end

  def test_toast_dismisses_itself_and_sits_outside_the_message
    render_inline(ToastComponent.new(title: "Saved", variant: :success, delay: 3000)) { "Done." }

    assert_selector "[data-controller='cl-dismiss'][data-cl-dismiss-delay-value='3000'].bg-success-subtle"
    assert_selector "strong", text: "Saved"
    assert_selector "button[data-action='cl-dismiss#close']"
  end

  def test_toast_takes_close_button_options
    render_inline(ToastComponent.new(close: {label: "Dismiss", class: "top-0 size-4", data: {action: "click->analytics#track"}})) { "Done." }

    button = page.find("button[aria-label=Dismiss]")
    classes = button[:class].split
    assert_equal "cl-dismiss#close click->analytics#track", button["data-action"]
    assert_includes classes, "top-0"
    assert_includes classes, "size-4"
    assert_includes classes, "absolute"
    refute_includes classes, "top-2"
    refute_includes classes, "size-[1em]"
  end

  def test_toast_fits_a_narrow_screen
    render_inline(ToastComponent.new) { "Done." }

    assert_selector "[class~='w-[min(350px,calc(100vw-1.5rem))]']"
  end

  def test_toast_without_close_button
    render_inline(ToastComponent.new(dismissible: false)) { "Done." }

    assert_no_selector "button"
  end

  def test_toast_container_is_a_live_region
    render_inline(ToastContainerComponent.new(placement: :bottom_end))

    assert_selector "#toasts[aria-live=polite][aria-atomic=false].bottom-0.right-0"
    assert_raises(ArgumentError) { render_inline(ToastContainerComponent.new(placement: :nowhere)) }
  end

  def test_tooltip_wraps_content_and_renders_a_manual_popover
    render_inline(TooltipComponent.new(text: "Copy it", placement: "bottom")) { "<button>Copy</button>".html_safe }

    assert_selector "span[data-controller=cl-tooltip][data-cl-tooltip-placement-value=bottom] > button", text: "Copy"
    tip_id = page.find("[role=tooltip]", visible: :all)[:id]
    assert_selector "##{tip_id}[role=tooltip][popover=manual]", text: "Copy it", visible: :all
    assert_includes page.find("span[data-controller]")[:"data-action"], "keydown.esc->cl-tooltip#hide"
  end
end
