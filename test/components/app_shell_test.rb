require "test_helper"

class AppShellTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def render_navbar(**options)
    render_inline(NavbarComponent.new(label: "Main", **options)) do |navbar|
      navbar.with_brand(href: "/") { "2100" }
      navbar.with_item("Projects", href: "/projects", active: true)
      navbar.with_item("Clients", href: "/clients")
      navbar.with_actions { "<button id='account'>Account</button>".html_safe }
    end
  end

  def test_navbar_is_a_labelled_landmark_with_brand_items_and_actions
    render_navbar

    assert_selector "nav[aria-label=Main].bg-light > a[href='/']", text: "2100"
    assert_selector "nav > ul.hidden.lg\\:flex li a[href='/projects'][aria-current=page]", text: "Projects"
    assert_selector "nav > ul a[href='/clients']:not([aria-current])", text: "Clients"
    assert_selector "nav > div.ml-auto button#account", count: 1
  end

  def test_navbar_collapses_items_into_an_offcanvas_behind_a_menu_button
    render_navbar(id: "top")

    button = page.find("button[aria-controls='top-menu']")
    assert_equal "Menu", button["aria-label"]
    assert_equal "false", button["aria-expanded"]
    assert_equal "dialog", button["aria-haspopup"]
    assert_includes button["class"], "lg:hidden"
    assert_includes button["data-action"], "cl-dialog#open"
    assert_equal "trigger", button["data-cl-dialog-target"]
    assert_selector "button svg[aria-hidden=true]"

    assert_selector "dialog#top-menu[aria-labelledby]", visible: :all
    assert_selector "dialog#top-menu h5", text: "Menu", visible: :all
    assert_selector "dialog#top-menu ul.flex-col a[href='/projects'][aria-current=page]", visible: :all
    assert_no_selector "dialog#account", visible: :all
  end

  def test_navbar_expand_options
    render_navbar(expand: :md)
    assert_selector "ul.md\\:flex"
    assert_selector "button.md\\:hidden[aria-controls]"

    render_navbar(expand: true)
    assert_no_selector "dialog", visible: :all
    assert_no_selector "button[aria-controls]"
    assert_selector "nav > ul.flex-row:not(.hidden)"

    render_navbar(expand: false)
    assert_selector "nav > ul.hidden"
    assert_selector "button[aria-controls].inline-block:not([class*=hidden])"

    assert_raises(ArgumentError) { render_navbar(expand: :huge) }
  end

  def test_navbar_dark_theme_uses_dark_tokens_and_a_white_close_button
    render_navbar(theme: :dark, menu_label: "Navigation", placement: :start)

    assert_selector "nav.bg-dark.text-dark-on"
    assert_selector "nav > ul a.text-dark-on\\/55", text: "Clients"
    assert_selector "button[aria-label=Navigation]"
    assert_selector "dialog.bg-dark.text-dark-on.left-0", visible: :all
    assert_selector "dialog button.text-white[aria-label=Close]", visible: :all
  end

  def test_navbar_surface_theme_follows_the_page_tokens
    render_navbar(theme: :surface)

    assert_selector "nav.bg-surface.text-body"
    assert_selector "nav > ul a.text-body-muted", text: "Clients"
    assert_selector "dialog.bg-surface.text-body", visible: :all
    assert_selector "dialog button.text-close[aria-label=Close]", visible: :all
  end

  def test_navbar_without_items_has_no_menu
    render_inline(NavbarComponent.new) { |navbar| navbar.with_brand("2100") }

    assert_selector "nav > span", text: "2100"
    assert_no_selector "ul"
    assert_no_selector "button"
  end

  def test_stepper_derives_states_from_current
    render_inline(StepperComponent.new(label: "Project status", current: 3)) do |stepper|
      %w[Draft Proposed Approved In\ progress Complete].each { |name| stepper.with_step(name) }
    end

    assert_selector "ol[aria-label='Project status'] > li", count: 5
    assert_selector "li[data-state=complete]", count: 2
    assert_selector "li[data-state=current] [aria-current=step]", text: "Approved"
    assert_selector "[aria-current=step]", count: 1
    assert_selector "li[data-state=upcoming]", count: 2
    assert_selector "li[data-state=complete] .sr-only", text: "(completed)", count: 2
    assert_selector "li[data-state=complete] span[aria-hidden=true] svg", count: 2
    assert_selector "li[data-state=upcoming] span[aria-hidden=true]", text: "5"
    assert_selector "ol.md\\:flex-row"
  end

  def test_stepper_links_and_hints
    render_inline(StepperComponent.new(label: "Onboarding", breakpoint: false, complete_text: nil)) do |stepper|
      stepper.with_step("Account", state: :complete, href: "/account", hint: "Done")
      stepper.with_step("Team", state: :current, href: "/team")
      stepper.with_step("Billing", state: :upcoming, hint: "Next")
    end

    link = page.find("a[href='/account']")
    assert_selector "##{link["aria-describedby"]}", text: "Done"
    assert_selector "a[href='/team'][aria-current=step]"
    assert_selector "li:last-child > span:not([aria-describedby])", text: "Billing"
    assert_selector "li:last-child > span.text-sm", text: "Next"
    assert_no_selector ".sr-only"
    assert_no_selector "ol[class*=flex-row]"
    assert_no_selector "li[class*=':flex-1']"
  end

  def test_stepper_stacks_first_and_switches_to_a_row_at_its_breakpoint
    render_inline(StepperComponent.new(label: "Steps", breakpoint: :lg)) { |stepper| stepper.with_step("One", href: "/one", hint: "Hi") }

    assert_selector "ol.flex-col.lg\\:flex-row:not(.md\\:flex-row)"
    assert_selector "li.pb-6.lg\\:flex-1.lg\\:pb-0"
    assert_selector "a.lg\\:flex-col.lg\\:text-center"
    assert_selector "span.pl-11.lg\\:pl-0", text: "Hi"

    render_inline(StepperComponent.new(label: "Steps", breakpoint: :xxl)) { |stepper| stepper.with_step("One") }
    assert_selector "ol[class~='2xl:flex-row']"

    assert_raises(ArgumentError) { StepperComponent.new(label: "Steps", breakpoint: :huge) }
  end

  def test_stepper_buttons_submit_the_surrounding_form
    render_inline(StepperComponent.new(label: "Plan", current: 2)) do |stepper|
      stepper.with_step("What", name: "step", value: "what")
      stepper.with_step("When", name: "step", value: "when", form: "plan-form")
      stepper.with_step("Who", name: "step", value: "who", disabled: true)
    end

    assert_selector "button[type=submit][name=step][value=what]", text: "What"
    assert_selector "button[value=when][form=plan-form][aria-current=step]"
    assert_selector "button[value=who][disabled]"
  end

  def test_stepper_rejects_unknown_states
    assert_raises(ArgumentError) do
      render_inline(StepperComponent.new(label: "x")) { |stepper| stepper.with_step("A", state: :done) }
    end
  end

  def test_helpers_render_navbar_and_stepper
    render_in_view_context do
      safe_join([
        ui_navbar(label: "Main") { |navbar| navbar.with_item("Home", href: "/") },
        ui_stepper(label: "Steps", current: 1) { |stepper| stepper.with_step("One") }
      ])
    end

    assert_selector "nav[aria-label=Main] a[href='/']", text: "Home"
    assert_selector "ol[aria-label=Steps] [aria-current=step]", text: "One"
  end
end
