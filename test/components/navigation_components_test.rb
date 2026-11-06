require "test_helper"

class NavigationComponentsTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_breadcrumb_marks_the_last_item_current
    render_inline(BreadcrumbComponent.new) do |crumbs|
      crumbs.with_item("Home", href: "/")
      crumbs.with_item("Library")
    end

    assert_selector "nav[aria-label=breadcrumb] ol li a[href='/']", text: "Home"
    assert_selector "li[aria-current=page]", text: "Library"
    assert_no_selector "li[aria-current=page] a"
  end

  def test_pagination_states
    render_inline(PaginationComponent.new(size: :lg)) do |pages|
      pages.with_item("Prev", disabled: true)
      pages.with_item("1", href: "?page=1", active: true)
      pages.with_item("2", href: "?page=2")
    end

    assert_selector "nav[aria-label=Pagination] ul li", count: 3
    assert_selector "span[aria-disabled=true]", text: "Prev"
    assert_selector "span[aria-current=page]", text: "1"
    assert_selector "a[href='?page=2'].px-6", text: "2"
  end

  def test_list_group_renders_ul_of_li
    render_inline(ListGroupComponent.new) do |list|
      list.with_item { "One" }
      list.with_item(active: true) { "Two" }
    end

    assert_selector "ul > li", count: 2
    assert_selector "li[aria-current=true].bg-primary", text: "Two"
  end

  def test_list_group_with_links_renders_div_of_anchors
    render_inline(ListGroupComponent.new) do |list|
      list.with_item(href: "/a") { "A" }
      list.with_item(href: "/b", disabled: true) { "B" }
    end

    assert_selector "div > a[href='/a']"
    assert_selector "a[aria-disabled=true]", text: "B"
  end
end
