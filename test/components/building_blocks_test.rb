require "test_helper"

# v0.4.0: Nav, the Dropdown's form items, the styled confirm dialog and the extras.
class BuildingBlocksTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_nav_renders_links_with_the_current_page_marked
    render_inline(NavComponent.new(label: "Account")) do |nav|
      nav.with_item("Profile", href: "/profile", active: true)
      nav.with_item("Billing", href: "/billing")
      nav.with_item("Archived", href: "/archived", disabled: true)
    end

    assert_selector "nav[aria-label=Account] > ul.border-b > li > a", count: 3
    assert_selector "a[href='/profile'][aria-current=page]", text: "Profile"
    assert_selector "a[href='/billing']:not([aria-current])"
    assert_selector "a[href='/archived'][aria-disabled=true][tabindex='-1']"
  end

  def test_nav_pills_fill_and_attributes
    render_inline(NavComponent.new(style: :pills, justified: true, id: "sections", class: "mb-4")) do |nav|
      nav.with_item(href: "/a", data: {turbo_frame: "main"}) { "A" }
    end

    assert_no_selector "nav"
    assert_selector "ul#sections.gap-1.mb-4 > li.basis-0.grow > a[data-turbo-frame=main]", text: "A"
    assert_includes page.find("a")[:class], "aria-[current=page]:bg-primary"
    assert_raises(ArgumentError) { render_inline(NavComponent.new(style: :cards)) { |n| n.with_item("x", href: "/") } }
  end

  def test_dropdown_item_with_a_method_is_a_button_to_form
    render_inline(DropdownComponent.new) do |menu|
      menu.with_trigger { "Me" }
      menu.with_item("Profile", href: "/profile")
      menu.with_item("Sign out", href: "/session", method: :delete, params: {all: 1}, data: {turbo_confirm: "Sure?"})
      menu.with_item("Refresh", href: "/refresh", method: :get)
    end

    assert_selector "[role=menu] form.m-0[action='/session'][method=post] input[name=_method][value=delete]", visible: :all
    assert_selector "form input[type=hidden][name=all][value='1']", visible: :all
    button = page.find("form button[role=menuitem]", text: "Sign out", visible: :all)
    assert_equal "submit", button[:type]
    assert_equal "-1", button[:tabindex]
    assert_equal "click->cl-popover#close", button["data-action"]
    assert_equal "Sure?", button["data-turbo-confirm"]
    assert_selector "a[role=menuitem][href='/refresh']", visible: :all
    assert_selector "a[role=menuitem][href='/profile']", visible: :all
  end

  def test_confirm_dialog_is_a_modal_wired_to_cl_confirm
    render_inline(ConfirmDialogComponent.new(id: "confirm", accept: "Delete"))

    assert_selector "[data-controller=cl-confirm][data-cl-confirm-accept-value=Delete][data-cl-confirm-title-value='Are you sure?']" \
                    "[data-action='cl-confirm:open@window->cl-confirm#open']"
    dialog = page.find("[data-controller=cl-confirm] dialog#confirm[role=alertdialog]", visible: :all)
    assert_equal "confirm-title", dialog["aria-labelledby"]
    assert_equal "confirm-message", dialog["aria-describedby"]
    assert_equal "click->cl-dialog#backdrop close->cl-confirm#cancel", dialog["data-action"]
    assert_selector "dialog h2#confirm-title[data-cl-confirm-target=title]", text: "Are you sure?", visible: :all
    assert_selector "dialog p#confirm-message[data-cl-confirm-target=message]", visible: :all
    assert_selector "dialog button.bg-secondary[autofocus][data-action='cl-confirm#cancel']", text: "Cancel", visible: :all
    assert_selector "dialog button.bg-danger[data-cl-confirm-target=accept][data-action='cl-confirm#accept']", text: "Delete", visible: :all
  end

  def test_page_header_lays_out_its_slots
    render_inline(PageHeaderComponent.new(title: "Projects", subtitle: "All of them", class: "mb-6")) do |header|
      header.with_breadcrumb { "crumbs" }
      header.with_badge(variant: :success) { "Live" }
      header.with_actions { "buttons" }
    end

    assert_selector "div.flex-col.mb-6 > div", text: "crumbs"
    assert_selector "h1", text: "Projects"
    assert_selector "h1 + span.bg-success", text: "Live"
    assert_selector "p.text-secondary", text: "All of them"
    assert_selector ".sm\\:flex-row > div.flex-wrap", text: "buttons"
  end

  def test_page_header_with_only_a_title
    render_inline(PageHeaderComponent.new(title: "Settings", level: 2))

    assert_selector "h2", text: "Settings"
    assert_no_selector "p"
  end

  def test_empty_state
    render_inline(EmptyStateComponent.new(title: "No projects", text: "Create one.")) do |empty|
      empty.with_icon { "<svg></svg>".html_safe }
      empty.with_action { "New" }
    end

    assert_selector "div.text-center > div[aria-hidden=true] svg", visible: :all
    assert_selector "h2", text: "No projects"
    assert_selector "p", text: "Create one."
    assert_selector "div.mt-3", text: "New"
  end

  def test_avatar_derives_initials_and_is_labelled
    render_inline(AvatarComponent.new(name: "ada king lovelace", variant: :primary, size: :sm))

    assert_selector "span[role=img][aria-label='ada king lovelace'].bg-primary.size-8 > span[aria-hidden=true]", text: "AL"
  end

  def test_avatar_initials_and_label_overrides
    assert_equal "C", AvatarComponent.initials_for("Cher")
    assert_equal "", AvatarComponent.initials_for(nil)
    assert_equal "ÉZ", AvatarComponent.initials_for(" éva  zed ")

    render_inline(AvatarComponent.new(initials: "Q"))
    assert_selector "span[aria-hidden=true].bg-secondary.size-10", text: "Q"
    assert_no_selector "[role=img]"
  end

  def test_new_helpers_render
    render_in_view_context do
      safe_join([
        ui_nav { |nav| nav.with_item("A", href: "/a") },
        ui_avatar(name: "Ada Lovelace"),
        ui_empty_state(title: "Empty"),
        ui_page_header(title: "Title"),
        ui_confirm_dialog,
        ui_switch(name: "on", label: "On")
      ])
    end

    assert_selector "ul a[href='/a']"
    assert_selector "[role=img]", text: "AL"
    assert_selector "h2", text: "Empty"
    assert_selector "h1", text: "Title"
    assert_selector "[data-controller=cl-confirm]"
    assert_selector "input[role=switch]"
  end
end
