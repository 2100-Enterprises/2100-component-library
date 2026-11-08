require "system_test_case"

# Checks the harness itself: the library's controllers load and connect, and Turbo Frames reach
# endpoints a test serves.
class HarnessSystemTest < SystemTestCase
  test "a dismissible alert closes" do
    render_page <<~ERB
      <%= ui_alert "Saved.", dismissible: true %>
    ERB

    assert_text "Saved."
    click_on "Close"
    assert_no_text "Saved."
  end

  test "a modal opens and closes on Escape" do
    render_page <<~ERB
      <%= ui_modal title: "Delete project" do |modal| %>
        <% modal.with_trigger { "Open" } %>
        Are you sure?
      <% end %>
    ERB

    click_on "Open"
    assert_selector "dialog[open]", text: "Are you sure?"

    find("dialog[open]").send_keys(:escape)
    assert_no_selector "dialog[open]"
  end

  test "a Turbo Frame loads from an endpoint the test serves" do
    serve("/greeting") { render_html(%(<turbo-frame id="greeting">Hello from the server</turbo-frame>)) }

    render_page <<~ERB
      <turbo-frame id="greeting" src="/greeting">Loading</turbo-frame>
    ERB

    assert_text "Hello from the server"
  end
end
