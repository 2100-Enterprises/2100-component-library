require "system_test_case"

# The install banner stays hidden until the browser offers to install (beforeinstallprompt), hands
# the click to the browser's own prompt, and remembers a dismissal. Headless Chrome never fires
# beforeinstallprompt by itself, so the tests dispatch a stand-in with the same shape.
class PwaInstallSystemTest < SystemTestCase
  BANNER = %(<%= ui_pwa_install app_name: "2100", icon: false %>)

  # Starts each test with no remembered dismissal, which a previous test may have left.
  def render_banner
    render_page BANNER
    execute_script("localStorage.clear()")
    render_page BANNER
  end

  def offer_install(outcome: "accepted")
    execute_script(<<~JS)
      window.prompted = false
      const event = new Event("beforeinstallprompt", { cancelable: true })
      event.prompt = () => { window.prompted = true }
      event.userChoice = Promise.resolve({ outcome: "#{outcome}" })
      window.dispatchEvent(event)
    JS
  end

  def record_events
    execute_script(<<~JS)
      window.installEvents = []
      for (const name of ["shown", "accepted", "declined", "dismissed"]) {
        document.addEventListener(`cl-pwa-install:${name}`, (event) => window.installEvents.push(name))
      }
    JS
  end

  test "stays hidden until the browser offers to install" do
    render_banner

    assert_no_text "Install 2100"
    offer_install

    assert_text "Install 2100"
    assert_button "Install"
    assert_no_text "Add to Home Screen"
  end

  test "Install opens the browser's prompt and removes the banner" do
    render_banner
    record_events
    offer_install

    click_on "Install"

    assert_no_text "Install 2100"
    assert evaluate_script("window.prompted")
    assert_equal %w[shown accepted], evaluate_script("window.installEvents")
  end

  test "reports a declined prompt" do
    render_banner
    record_events
    offer_install(outcome: "dismissed")

    click_on "Install"

    assert_no_text "Install 2100"
    assert_equal %w[shown declined], evaluate_script("window.installEvents")
  end

  test "Not now hides it, and it stays hidden on the next visit" do
    render_banner
    offer_install
    click_on "Not now"
    assert_no_text "Install 2100"

    render_page BANNER
    offer_install

    assert_no_text "Install 2100"
    assert_selector "[data-controller=cl-pwa-install][hidden]", visible: :all
  end

  test "the close button dismisses it too" do
    render_banner
    record_events
    offer_install

    click_on "Dismiss install prompt"

    assert_no_text "Install 2100"
    assert_equal %w[shown dismissed], evaluate_script("window.installEvents")
  end
end
