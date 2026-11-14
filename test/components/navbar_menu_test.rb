require "test_helper"

class NavbarMenuTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def render_nav(**options, &extra)
    render_inline(NavbarComponent.new(label: "Main", id: "top", **options)) do |navbar|
      navbar.with_item("Projects", href: "/projects")
      navbar.with_menu("Content", **(extra ? extra.call : {})) do |menu|
        menu.with_item("Planned Posts", href: "/p", active: true)
        menu.with_item("Drafts", href: "/d")
      end
      navbar.with_item("Clients", href: "/clients")
    end
  end

  def first_word(node) = node.text(:all).strip[/\A(Projects|Content|Clients)/]

  def test_entries_render_in_call_order_in_the_bar
    render_nav

    assert_equal(%w[Projects Content Clients], page.all("nav > ul > li", visible: :all).map { |li| first_word(li) })
  end

  def test_bar_renders_a_dropdown_trigger_styled_as_a_link
    render_nav

    assert_selector "nav > ul > li > div[data-controller=cl-popover]"
    trigger = page.find("nav > ul button[aria-haspopup=menu]", text: "Content")
    assert_includes trigger["class"], "text-light-on/55"
    assert_includes trigger["class"], "after:border-t-[.3em]"
    assert_equal "true", trigger["data-current"]
    assert_nil trigger["aria-current"]
    assert_selector "nav > ul [role=menu] a[role=menuitem][href='/p'][aria-current=page]", visible: :all
    assert_selector "nav > ul [role=menu] a[href='/d']:not([aria-current])", visible: :all
  end

  def test_trigger_is_current_when_active_or_any_child_is_active
    render_inline(NavbarComponent.new) do |navbar|
      navbar.with_menu("Idle") { |menu| menu.with_item("A", href: "/a") }
      navbar.with_menu("Flagged", active: true) { |menu| menu.with_item("B", href: "/b") }
      navbar.with_menu("Child") { |menu| menu.with_item("C", href: "/c", active: true) }
    end

    assert_no_selector "nav > ul button[data-current]", text: "Idle"
    assert_selector "nav > ul button[data-current=true]", text: "Flagged"
    assert_selector "nav > ul button[data-current=true]", text: "Child"
    assert_no_selector "button[aria-current]"
  end

  def test_offcanvas_renders_a_labelled_list_without_a_dropdown
    render_nav

    panel = page.find("dialog#top-menu", visible: :all)
    label = panel.find("span", text: "Content", visible: :all)
    assert label[:id].present?
    group = panel.find("ul[aria-labelledby='#{label[:id]}']", visible: :all)
    assert_equal "li", label.find(:xpath, "..", visible: :all).tag_name
    assert_equal label.find(:xpath, "..", visible: :all), group.find(:xpath, "..", visible: :all)
    assert_equal(["Planned Posts", "Drafts"], group.all("li a", visible: :all).map { |a| a.text(:all) })
    assert group.has_css?("a[href='/p'][aria-current=page]", visible: :all)
    assert_no_selector "dialog [role=menu], dialog [popover], dialog [aria-haspopup=menu]", visible: :all
    assert_nil group[:role]
  end

  def test_offcanvas_keeps_call_order
    render_nav

    tops = page.all(:xpath, "//dialog[@id='top-menu']//ul[not(ancestor::li)]/li", visible: :all)
    assert_equal(%w[Projects Content Clients], tops.map { |li| first_word(li) })
  end

  def test_ids_are_not_duplicated
    render_nav
    ids = page.all("[id]", visible: :all).map { |e| e[:id] }
    assert_equal ids.uniq, ids

    render_inline(NavbarComponent.new) do |navbar|
      2.times { |i| navbar.with_menu("M#{i}") { |menu| menu.with_item("X", href: "/x") } }
    end
    ids = page.all("[id]", visible: :all).map { |e| e[:id] }
    assert_equal ids.uniq, ids
  end

  def test_menu_id_option_and_dropdown_options
    render_inline(NavbarComponent.new) do |navbar|
      navbar.with_menu("Content", id: "content", placement: "bottom-end", data: {x: "1"}) { |menu| menu.with_item("A", href: "/a") }
    end

    assert_selector "[role=menu]#content[data-x='1']", visible: :all
    assert_selector "span#content-label", text: "Content", visible: :all
    assert_selector "[data-cl-popover-placement-value=bottom-end]"
  end

  def test_menu_only_navbar_still_gets_the_menu_button
    render_inline(NavbarComponent.new(id: "n")) { |navbar| navbar.with_menu("Only") { |menu| menu.with_item("A", href: "/a") } }
    assert_selector "button[aria-controls='n-menu']"
  end

  def test_menu_item_block_content_and_link_options
    render_inline(NavbarComponent.new) do |navbar|
      navbar.with_menu("Content") do |menu|
        menu.with_item(href: "/a", data: {k: "v"}) { "Block" }
      end
    end
    assert_selector "[role=menu] a[href='/a'][data-k=v]", text: "Block", visible: :all
    assert_selector "dialog ul[aria-labelledby] a[href='/a'][data-k=v]", text: "Block", visible: :all
  end
end
