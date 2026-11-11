require "system_test_case"

# Modal and Offcanvas animate on open and on close with the library's real CSS, and a closing
# dialog stays in the top layer until its animation ends. Each test records the transitions
# the dialog and its backdrop start, then waits for them to finish.
class OverlayTransitionSystemTest < SystemTestCase
  MODAL = <<~ERB.freeze
    <%= ui_modal title: "Details" do |modal| %>
      <% modal.with_trigger { "Open" } %>
      Body
    <% end %>
  ERB

  OFFCANVAS = <<~ERB.freeze
    <%= ui_offcanvas title: "Filters", placement: :end do |panel| %>
      <% panel.with_trigger { "Open" } %>
      Body
    <% end %>
  ERB

  test "a modal fades in with its backdrop and fades out again" do
    render_page MODAL, styles: true
    record_transitions

    click_on "Open"
    assert_includes transitions_started, "opacity"
    assert_includes transitions_started, "translate"
    assert_includes transitions_started, "opacity::backdrop"
    settle
    assert_equal({"dialog" => "1", "backdrop" => "1"}, opacities)

    record_transitions
    find("dialog[open]").send_keys(:escape)
    assert_no_selector "dialog[open]"
    assert_includes transitions_started, "opacity"
    assert_includes transitions_started, "overlay"
    assert_includes transitions_started, "opacity::backdrop"
    assert_selector "dialog", text: "Body", visible: :visible, wait: 0
    settle
    assert_no_selector "dialog", visible: :visible
    assert_selector "button[aria-expanded='false']", text: "Open"
  end

  test "an offcanvas slides out on close instead of vanishing" do
    render_page OFFCANVAS, styles: true
    click_on "Open"
    settle
    assert_equal "1", opacities["backdrop"]

    record_transitions
    find("dialog[open]").click_on("Close")
    assert_no_selector "dialog[open]"
    assert_includes transitions_started, "translate"
    assert_includes transitions_started, "overlay"
    assert_includes transitions_started, "opacity::backdrop"
    settle
    assert_no_selector "dialog", visible: :visible
  end

  test "a closing modal or offcanvas keeps its column layout while it animates out" do
    {"Modal" => MODAL, "Offcanvas" => OFFCANVAS}.each do |name, erb|
      render_page erb, styles: true
      click_on "Open"
      settle

      assert_equal({"display" => "flex", "direction" => "column"}, layout_as_it_closes, name)
    end
  end

  test "under prefers-reduced-motion a modal opens and closes without animating" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [{name: "prefers-reduced-motion", value: "reduce"}])
    render_page MODAL, styles: true
    record_transitions

    click_on "Open"
    assert_selector "dialog[open]"
    find("dialog[open]").send_keys(:escape)
    assert_no_selector "dialog", visible: :visible
    assert_empty transitions_started
  ensure
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [])
  end

  private

  # Starts a fresh list of the transitions that start on a dialog or its backdrop, as "property"
  # or "property::backdrop". Buttons inside have focus transitions of their own, left out.
  def record_transitions
    execute_script(<<~JS)
      window.transitions = []
      if (!window.recording) {
        window.recording = true
        document.addEventListener("transitionrun", (event) => {
          if (event.target.localName === "dialog") window.transitions.push(event.propertyName + event.pseudoElement)
        })
      }
    JS
  end

  # The list after two frames, by which time any transition a style change caused has started.
  def transitions_started
    evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1]
      requestAnimationFrame(() => requestAnimationFrame(() => done([...new Set(window.transitions)])))
    JS
  end

  # Waits for every transition in the dialog and on its backdrop to finish or be cancelled.
  def settle
    evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1]
      const dialog = document.querySelector("dialog")
      const finished = dialog.getAnimations({ subtree: true }).map((animation) => animation.finished.catch(() => {}))
      Promise.all(finished).then(() => done(true))
    JS
  end

  # Closes the dialog and reads its layout in the same task, while the exit transition holds
  # it on screen.
  def layout_as_it_closes
    evaluate_script(<<~JS)
      (() => {
        const dialog = document.querySelector("dialog")
        dialog.close()
        const style = getComputedStyle(dialog)
        return { display: style.display, direction: style.flexDirection }
      })()
    JS
  end

  def opacities
    evaluate_script(<<~JS)
      (() => {
        const dialog = document.querySelector("dialog")
        return { dialog: getComputedStyle(dialog).opacity, backdrop: getComputedStyle(dialog, "::backdrop").opacity }
      })()
    JS
  end
end
