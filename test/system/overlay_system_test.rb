require "system_test_case"

# The built-in triggers keep aria-expanded in step with the dialog they open.
class OverlaySystemTest < SystemTestCase
  test "opening a modal sets aria-expanded and Escape resets it" do
    render_page <<~ERB
      <%= ui_modal title: "Details" do |modal| %>
        <% modal.with_trigger { "Open" } %>
        Body
      <% end %>
    ERB

    assert_selector "button[aria-expanded='false']", text: "Open"
    click_on "Open"
    assert_selector "dialog[open]"
    assert_selector "button[aria-expanded='true']", text: "Open", visible: :all

    find("dialog[open]").send_keys(:escape)
    assert_no_selector "dialog[open]"
    assert_selector "button[aria-expanded='false']", text: "Open"
  end

  test "opening an offcanvas sets aria-expanded and Escape resets it" do
    render_page <<~ERB
      <%= ui_offcanvas title: "Filters" do |panel| %>
        <% panel.with_trigger { "Filters" } %>
        Body
      <% end %>
    ERB

    click_on "Filters"
    assert_selector "dialog[open]"
    assert_selector "button[aria-expanded='true']", text: "Filters", visible: :all

    find("dialog[open]").send_keys(:escape)
    assert_no_selector "dialog[open]"
    assert_selector "button[aria-expanded='false']", text: "Filters"
  end
end
