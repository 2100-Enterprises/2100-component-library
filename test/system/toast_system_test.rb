require "system_test_case"

# Toast pauses its auto-dismiss on hover, focus and a hidden tab, so it can't vanish while someone
# reads it or tabs to its close button.
class ToastSystemTest < SystemTestCase
  test "an untouched toast closes after its delay" do
    render_page %(<%= ui_toast "Saved", delay: 400 %>)

    assert_text "Saved"
    assert_no_text "Saved", wait: 3
  end

  test "a hovered toast survives its delay and closes after the pointer leaves" do
    render_page <<~ERB
      <%= ui_toast "Saved", delay: 600 %>
      <p id="elsewhere" style="margin-top: 200px">Elsewhere</p>
    ERB

    find("[data-controller~=cl-dismiss]").hover
    sleep 1.2
    assert_text "Saved"

    find("#elsewhere").hover
    assert_no_text "Saved", wait: 3
  end

  test "remaining time is kept, not restarted, on resume" do
    render_page <<~ERB
      <%= ui_toast "Saved", delay: 1500 %>
      <p id="elsewhere" style="margin-top: 200px">Elsewhere</p>
    ERB

    sleep 1.0
    find("[data-controller~=cl-dismiss]").hover
    sleep 0.5
    find("#elsewhere").hover
    left_at = Time.now
    assert_no_text "Saved", wait: 3
    assert_operator Time.now - left_at, :<, 1.2
  end

  test "a focused toast survives its delay and closes after focus moves away" do
    render_page <<~ERB
      <%= ui_toast "Saved", delay: 500 %>
      <button id="other">Other</button>
    ERB

    page.execute_script("document.querySelector('[data-controller~=cl-dismiss] button').focus()")
    sleep 1.0
    assert_text "Saved"

    page.execute_script("document.getElementById('other').focus()")
    assert_no_text "Saved", wait: 3
  end

  test "a hidden tab holds the countdown until it is visible again" do
    render_page %(<%= ui_toast "Saved", delay: 500 %>)

    page.execute_script <<~JS
      Object.defineProperty(document, "visibilityState", {configurable: true, get: () => "hidden"})
      document.dispatchEvent(new Event("visibilitychange"))
    JS
    sleep 1.0
    assert_text "Saved"

    page.execute_script <<~JS
      Object.defineProperty(document, "visibilityState", {configurable: true, get: () => "visible"})
      document.dispatchEvent(new Event("visibilitychange"))
    JS
    assert_no_text "Saved", wait: 3
  end

  test "a dismissible alert with no delay never closes by itself" do
    render_page <<~ERB
      <%= ui_alert "Heads up", dismissible: true %>
      <button id="other">Other</button>
    ERB

    find("[role=alert]").hover
    page.execute_script("document.getElementById('other').focus()")
    sleep 1.0
    assert_text "Heads up"
  end
end
