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

  test "a modal and an offcanvas keep scrolling from reaching the page behind" do
    render_page <<~ERB, styles: true
      <div style="height: 300vh">Long page</div>
      <%= ui_modal title: "Details" do |modal| %>
        <% modal.with_trigger { "Open details" } %>
        Body
      <% end %>
      <%= ui_offcanvas title: "Filters" do |panel| %>
        <% panel.with_trigger { "Open filters" } %>
        Body
      <% end %>
    ERB

    [ "Open details", "Open filters" ].each do |trigger|
      click_on trigger
      assert_selector "dialog[open]"
      styles = evaluate_script(<<~JS)
        (() => {
          const dialog = document.querySelector("dialog[open]")
          const backdrop = getComputedStyle(dialog, "::backdrop")
          return [getComputedStyle(dialog).overscrollBehaviorY, backdrop.overflowY, backdrop.overscrollBehaviorY]
        })()
      JS
      assert_equal %w[contain hidden contain], styles, trigger

      find("dialog[open]").send_keys(:escape)
      assert_no_selector "dialog[open]"
    end
  end
end
