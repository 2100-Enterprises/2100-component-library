require "system_test_case"

class CardLinkSystemTest < SystemTestCase
  def page_with_card
    render_page <<~ERB, styles: true
      <%= ui_card href: "/post", link_label: "Launch post", class: "w-72", id: "card" do %>
        <p>Launch post</p>
        <button type="button" class="relative z-10" onclick="document.title = 'archived'">Archive</button>
      <% end %>
    ERB
    serve("/post") { render_html("<p>The post page</p>") }
  end

  test "clicking the card text follows the link" do
    page_with_card
    find("#card a").click
    assert_text "The post page"
  end

  test "a nested control stays clickable and does not follow the link" do
    page_with_card
    click_on "Archive"
    assert_equal "archived", page.title
    assert_no_text "The post page"
  end

  test "the link is reachable by keyboard and the card shows a focus ring" do
    page_with_card
    find("body").send_keys(:tab)
    assert_equal "Launch post", page.evaluate_script("document.activeElement.getAttribute('aria-label')")
    shadow = page.evaluate_script("getComputedStyle(document.getElementById('card')).boxShadow")
    refute_equal "none", shadow
  end
end
