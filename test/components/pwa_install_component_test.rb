require "test_helper"

class PwaInstallComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  # The controller decides whether installing can work here, so nothing shows until it does.
  def test_renders_hidden_and_wired_to_the_controller
    render_inline(PwaInstallComponent.new(app_name: "2100 Enterprises"))

    root = page.find("[data-controller='cl-pwa-install']", visible: :all)
    assert root[:hidden]
    assert_equal "30", root["data-cl-pwa-install-dismiss-days-value"]
    assert_equal "Install 2100 Enterprises", root["aria-label"]
    assert_selector "[data-cl-pwa-install-target=promptActions][hidden]", visible: :all
    assert_selector "[data-cl-pwa-install-target=iosActions][hidden]", visible: :all
  end

  def test_prompt_actions_install_and_dismiss
    render_inline(PwaInstallComponent.new(app_name: "2100", install_label: "Get the app"))

    actions = page.find("[data-cl-pwa-install-target=promptActions]", visible: :all)
    assert actions.has_selector?("button[data-action='cl-pwa-install#install']", text: "Get the app", visible: :all)
    assert actions.has_selector?("button[data-action='cl-pwa-install#dismiss']", text: "Not now", visible: :all)
    assert actions.has_text?(:all, "Add 2100 to your home screen")
  end

  def test_ios_actions_guide_to_add_to_home_screen
    render_inline(PwaInstallComponent.new(app_name: "2100"))

    actions = page.find("[data-cl-pwa-install-target=iosActions]", visible: :all)
    assert actions.has_text?(:all, "Tap the Share button, then Add to Home Screen.")
    assert actions.has_selector?("button[data-action='cl-pwa-install#dismiss']", text: "Got it", visible: :all)
  end

  def test_close_button_dismisses
    render_inline(PwaInstallComponent.new(app_name: "2100"))

    assert_selector "button[aria-label='Dismiss install prompt'][data-action='cl-pwa-install#dismiss']", visible: :all
  end

  def test_uses_the_shared_icon_unless_told_otherwise
    render_inline(PwaInstallComponent.new(app_name: "2100"))
    assert_selector "img[src*='component_library_2100/pwa/icon-192'][alt='']", visible: :all

    render_inline(PwaInstallComponent.new(app_name: "2100", icon: false))
    assert_no_selector "img", visible: :all
  end

  def test_custom_messages_and_attributes
    render_inline(PwaInstallComponent.new(app_name: "2100", message: "Faster next time.", ios_message: "Use Share.",
      dismiss_days: 7, id: "install", class: "sm:max-w-md", data: {action: "cl-pwa-install:shown->analytics#track"}))

    root = page.find("#install", visible: :all)
    assert_includes root[:class], "sm:max-w-md"
    refute_includes root[:class], "sm:max-w-sm"
    assert_equal "cl-pwa-install", root["data-controller"]
    assert_equal "cl-pwa-install:shown->analytics#track", root["data-action"]
    assert_equal "7", root["data-cl-pwa-install-dismiss-days-value"]
    assert root.has_text?(:all, "Faster next time.")
    assert root.has_text?(:all, "Use Share.")
  end

  def test_buttons_meet_the_touch_target
    render_inline(PwaInstallComponent.new(app_name: "2100"))

    page.all("[data-cl-pwa-install-target] button", visible: :all).each do |button|
      assert_includes button[:class], "min-h-11", button.text
    end
  end
end
